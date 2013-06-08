casper = require("casper").create({verbose:true, logLevel:'debug'})
if casper.cli.args.length < 1
  casper.exit()

siteURL = casper.cli.args[0]
casper.log("site: #{siteURL}", 'info')

casper.start siteURL + "/", ->
  casper.log('accessing /', 'info')
  @capture('screenshot/surf_index.png')
   
casper.run ->
  @exit()
