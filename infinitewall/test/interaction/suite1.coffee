casper = require("casper").create({verbose:true, logLevel:'debug', viewportSize:{width:1280, height:1024}})
if casper.cli.args.length < 1
  casper.exit()

siteURL = casper.cli.args[0]
casper.log("site: #{siteURL}", 'debug')

# visit / 
casper.start siteURL + "/", ->
  casper.log('accessing /', 'info')
  @capture('screenshot/surf_index.png')

# visit /signup by clicking link
casper.then ->
  url = @getCurrentUrl()
  @thenClick('a[href="/signup"]').then ->
    @waitFor ( ->
      url isnt @getCurrentUrl()
    )

# fill signup form and submit
casper.then ->
  casper.log('accessing /signup', 'info')
  url = @getCurrentUrl()
  @fill( 'form[action="/users/create"]',{
    "Email": "casper@example.com"
    "Password.main": "blahblah"
    "Password.confirm": "blahblah"
    "Nickname": "casper"
  }
  ,true)
  @waitForSelector('a[href="/logout"]')

# capture index after login
casper.then ->
  @test.assertEquals(@getCurrentUrl(), siteURL + "/")
  casper.log('accessing '+ @getCurrentUrl(), 'info')
  @capture('screenshot/signedup_index.png')

# TODO: visit group page
# TODO: visit account page

# visit wall page
casper.thenOpen siteURL + '/wall', ->
  casper.log('accessing '+ @getCurrentUrl(), 'info')
  @capture('screenshot/wall.png')
  @fill('form[action="/wall/create"]', {
    "title" : "test wall"
  }
  ,true)
  @waitForSelector('div#wall')

# capture wall
casper.then ->
  casper.log('accessing '+ @getCurrentUrl(), 'info')
  @wait(5000)
  @capture('screenshot/stage.png')
  casper.thenClick('#newTextSheetButton').then ->
    @waitForSelector('.sheet[contenttype="text"]')
    @wait 1000, () ->
	    @capture('screenshot/create_textsheet.png')

# visit group page
casper.thenOpen siteURL + '/group', ->
  casper.log('accessing '+ @getCurrentUrl(), 'info')
  @capture('screenshot/group.png')

# log out
casper.then ->
  @thenClick('a[href="/logout"]').then ->
    @waitWhileSelector 'a[href="/logout"]'

# logged out, and then login again
casper.then ->
  @test.assertEquals(@getCurrentUrl(), siteURL + "/")
  casper.log('accessing '+ @getCurrentUrl(), 'info')
  @capture('screenshot/loggedout_index.png')
  @fill('form[action="/authenticate"]', {
    "email" : "casper@example.com"
    "password" : "blahblah"
  }
  , true)
  @waitForSelector('a[href="/logout"]')

# capture screen shot
casper.then ->
  @capture('screenshot/loggedin_index.png')

casper.run ->
  @exit()
