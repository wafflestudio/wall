casper = require("casper").create()
if casper.cli.args.length < 1
  casper.exit()

siteURL = casper.cli.args[0]
console.log(siteURL)

casper.start siteURL + "/", ->
  @capture('surf_index.png')
   
casper.run ->
  @exit()
