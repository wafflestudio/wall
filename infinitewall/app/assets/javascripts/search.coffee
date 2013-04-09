class window.Search
  constructor: ->
    @searchForm = $("#searchForm")
    @searchInput = $("#searchInput")
    @searchButton = $("#searchButton")
    @searchResult = $("#searchResult")

    @searchButton.click =>
      keyword = @searchInput.val()
      
      if keyword?
        $.get("/wall/search/#{stage.wallId}/#{keyword}", {},
          (res) ->
            console.log(res)
        )
      return
