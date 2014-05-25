assert = require('assert')
sinon = require('sinon')
fly = require('./../fly')

# get resources
person = require('./resources/person')
pet = require('./resources/pet')
feed = require('./resources/feed')

describe 'middleware', () ->
	
	# generate middleware
	middleware = fly(process.cwd() + '/test/resources')

	# generate req, res, next
	req = null
	res = null
	next = null

	beforeEach () ->
		# prepare req, res, next
		req = 
			url: null
			params: {}
			method: null
		res = {}
		next = sinon.spy()

		# spy on all resource actions
		# spy on person actions
		sinon.spy(person, 'index')
		sinon.spy(person, 'show')
		sinon.spy(person, 'create')
		sinon.spy(person, 'update')
		sinon.spy(person, 'destroy')

		# spy on pet actions
		sinon.spy(pet, 'index')
		sinon.spy(pet, 'show')
		sinon.spy(pet, 'create')
		sinon.spy(pet, 'update')
		sinon.spy(pet, 'destroy')

		# spy on feed actions
		sinon.spy(feed, 'index')
		sinon.spy(feed, 'show')
		sinon.spy(feed, 'create')
		sinon.spy(feed, 'update')
		sinon.spy(feed, 'destroy')

	afterEach () ->
		# unwrap spies
		# unwrap spies on person
		person.index.restore()
		person.show.restore()
		person.create.restore()
		person.update.restore()
		person.destroy.restore()

		# unwrap spies on pet
		pet.index.restore()
		pet.show.restore()
		pet.create.restore()
		pet.update.restore()
		pet.destroy.restore()

		# unwrap spies on feed
		feed.index.restore()
		feed.show.restore()
		feed.create.restore()
		feed.update.restore()
		feed.destroy.restore()

	describe 'when resource request has chaining relationships', () ->

		it 'calls index(req, res) action with parent_id', () ->
			req.method = 'GET'
			req.url = '/persons/1/pets/1/feeds'

			middleware(req, res, next)

			assert(feed.index.withArgs(req, res).calledOnce)

			# assert that other actions shouldn't been called
			assert(not feed.show.called)
			assert(not feed.create.called)
			assert(not feed.update.called)
			assert(not feed.destroy.called)

		it 'calls show(req, res) action with parent_id and id', () ->
			req.method = 'GET'
			req.url = '/persons/1/pets/1/feeds/1'

			middleware(req, res, next)

			assert(feed.show.withArgs(req, res).calledOnce)
			assert(req.params.pet_id?)
			assert(req.params.id?)
			
			# assert that other actions shouldn't been called
			assert(not feed.index.called)
			assert(not feed.create.called)
			assert(not feed.update.called)
			assert(not feed.destroy.called)

		it 'calls create(req, res) action with parent_id', () ->
			req.method = 'POST'
			req.url = '/persons/1/pets/1/feeds'

			middleware(req, res, next)

			assert(feed.create.withArgs(req, res).calledOnce)
			assert(req.params.pet_id?)

			# assert that other actions shouldn't been called
			assert(not feed.index.called)
			assert(not feed.show.called)
			assert(not feed.update.called)
			assert(not feed.destroy.called)

		it 'calls update(req, res) action with parent_id and id', () ->
			req.method = 'PUT'
			req.url = '/persons/1/pets/1/feeds/1'

			middleware(req, res, next)

			assert(feed.update.withArgs(req, res).calledOnce)
			assert(req.params.pet_id?)
			assert(req.params.id?)

			# assert that other actions shouldn't been called
			assert(not feed.index.called)
			assert(not feed.show.called)
			assert(not feed.create.called)
			assert(not feed.destroy.called)

		it 'calls destroy(req, res) action with parent_id and id', () ->
			req.method = 'DELETE'
			req.url = '/persons/1/pets/1/feeds/1'

			middleware(req, res, next)

			assert(feed.destroy.withArgs(req, res).calledOnce)
			assert(req.params.pet_id?)
			assert(req.params.id?)

			# assert that other actions shouldn't been called
			assert(not feed.index.called)
			assert(not feed.show.called)
			assert(not feed.create.called)
			assert(not feed.update.called)

		it 'calls destroy(req, res) action without id if not specified, but has parent_id', () ->
			req.method = 'DELETE'
			req.url = '/persons/1/pets/1/feeds'

			middleware(req, res, next)

			assert(feed.destroy.withArgs(req, res).calledOnce)
			assert(req.params.pet_id?)
			assert(not req.params.id?)

			# assert that other actions shouldn't been called
			assert(not feed.index.called)
			assert(not feed.show.called)
			assert(not feed.create.called)
			assert(not feed.update.called)

	describe 'when requested resource is single', () ->

		it 'calls index(req, res) action', () ->
			req.method = 'GET'
			req.url = '/persons'

			middleware(req, res, next)

			assert(person.index.withArgs(req, res).calledOnce)

			assert(not person.show.called)
			assert(not person.create.called)
			assert(not person.update.called)
			assert(not person.destroy.called)

		it 'calls show(req, res) action with id', () ->
			req.method = 'GET'
			req.url = '/persons/1'

			middleware(req, res, next)

			assert(person.show.withArgs(req, res).calledOnce)

			assert(not person.index.called)
			assert(not person.create.called)
			assert(not person.update.called)
			assert(not person.destroy.called)

		it 'calls create(req, res) action', () ->
			req.method = 'POST'
			req.url = '/persons'

			middleware(req, res, next)

			assert(person.create.withArgs(req, res).calledOnce)

			assert(not person.show.called)
			assert(not person.index.called)
			assert(not person.update.called)
			assert(not person.destroy.called)

		it 'calls update(req, res) action with id', () ->
			req.method = 'PUT'
			req.url = '/persons/1'

			middleware(req, res, next)

			assert(person.update.withArgs(req, res).calledOnce)

			assert(not person.show.called)
			assert(not person.create.called)
			assert(not person.index.called)
			assert(not person.destroy.called)

		it 'calls destroy(req, res) action with id', () ->
			req.method = 'DELETE'
			req.url = '/persons/1'

			middleware(req, res, next)

			assert(person.destroy.withArgs(req, res).calledOnce)

			assert(not person.show.called)
			assert(not person.create.called)
			assert(not person.update.called)
			assert(not person.index.called)

		it 'calls destroy(req, res) action without id if not specified', () ->
			req.method = 'DELETE'
			req.url = '/persons'

			middleware(req, res, next)

			assert(person.destroy.withArgs(req, res).calledOnce)

			assert(not person.show.called)
			assert(not person.create.called)
			assert(not person.update.called)
			assert(not person.index.called)

	describe 'when the requested resource has invalid relatiohsip chains', () ->

		beforeEach () ->
			req.method = 'GET'
			req.url = '/pets/1/feeds/1/persons/1'

			middleware(req, res, next)

		it 'must call next()', () ->
			assert(next.called)

		it 'must not call the action of the resource', () ->
			assert(not person.show.called)

	describe 'when the requested resource name is singular', () ->

		beforeEach () ->
			req.method = 'GET'
			req.url = '/person/1'

			middleware(req, res, next)

		it 'must call next()', () ->
			assert(next.called)

		it 'must not call the action of the resource', () ->
			assert(not person.show.called)

	describe 'when HTTP method is unsupported', () ->

		beforeEach () ->
			req.method = 'SOMETHING'
			req.url = '/persons/1'

			middleware(req, res, next)

		it 'must call next()', () ->
			assert(next.called)

	describe 'when POST request has specified resource id', () ->

		beforeEach () ->
			req.method = 'POST'
			req.url = '/persons/1'

			middleware(req, res, next)

		it 'must call next()', () ->
			assert(next.called)

		it 'must not call create() action', () ->
			assert(not person.create.called)

	describe 'when PUT request has no specified id', () ->

		beforeEach () ->
			req.method = 'PUT'
			req.url = '/persons'

			middleware(req, res, next)

		it 'must call next()', () ->
			assert(next.called)

		it 'must not call update() action', () ->
			assert(not person.update.called)
