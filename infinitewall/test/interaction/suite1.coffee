casper = require("casper").create({verbose:true, logLevel:'debug'})
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

casper.then ->
  casper.log('accessing '+ @getCurrentUrl(), 'info')
  @capture('screenshot/login_index.png')

casper.run ->
  @exit()
