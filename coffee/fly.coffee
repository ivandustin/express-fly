pluralize = require('pluralize')
URL = require('url')

getResource = (dir, name) ->
	try
		return require(dir + '/' + name)
	catch e
		return false

# request resource tokens
# [
# 	{
# 		name: 'person'
# 		plural: 'persons'
# 		id: '01'
# 	}
# 	{
# 		name: 'pet'
# 		plural: 'pets'
# 		id: null
# 	}
# ]
tokenizePath = (path) ->
	# normalize path
	# remove double slashes
	path = path.replace(/\/+/g, '/')
	# remove leading and trailing slashes
	path = path.replace(/^\/|\/$/g, '')

	tokens = []
	chunks = path.split('/')
	for i in [0...chunks.length] by 2
		# break if overshoot
		if i >= chunks.length
			break

		plural = chunks[i]

		# return false if not plural
		if pluralize.plural(plural) != plural
			return false

		# get singular
		singular = pluralize.singular(plural)

		# get id if any
		if i+1 < chunks.length
			id = chunks[i+1]
		else
			id = null

		resource = 
			name: singular
			plural: plural
			id: id

		tokens.push(resource)

	return tokens

module.exports = (resourceDir) ->
	# get relationships
	relationships = require(resourceDir + '/relationships')

	# generate middleware
	middleware = (req, res, next) ->

		# tokenize path
		tokens = tokenizePath(URL.parse(req.url).pathname)

		if tokens is false
			next()
			return

		# validate requested resources
		for resource in tokens
			if getResource(resourceDir, resource.name) == false
				next()
				return

		# validate relationships
		for i in [0...tokens.length]
			# break if there's no child
			if i+1 >= tokens.length
				break

			# get parent and child
			parent = tokens[i]
			child = tokens[i+1]

			# skip if invalid relationship
			if relationships[parent.name] != child.name
				next()
				return

		# get resource token
		resource = tokens.pop()
		
		# set request.params
		# apply resource id if any
		if resource.id
			req.params.id = resource.id
		# apply parent resource id if there's a parent
		parent = tokens.pop()
		if parent
			req.params[parent.name + '_id'] = parent.id

		# get resource object
		resourceObj = getResource(resourceDir, resource.name)

		# trigger resource object action
		switch req.method
			when 'GET'
				if resource.id?
					resourceObj.show(req, res)
				else
					resourceObj.index(req, res)
			when 'POST'
				# POST request must NOT have a resource id
				# skip if there is
				if not resource.id?
					resourceObj.create(req, res)
				else
					next()
					return
			when 'PUT'
				# PUT request must have a resource id
				# skip if none
				if resource.id?
					resourceObj.update(req, res)
				else
					next()
					return
			when 'DELETE'
				# DELETE request can either have resource id specified or none, so call anyway
				resourceObj.destroy(req, res)
			else
				# skip if HTTP method is not supported
				next()
				return
	
	# return the middleware
	return middleware
