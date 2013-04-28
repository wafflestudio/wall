searchTemplate = "<div class='searchResult'>
    <b id='title'></b>
    <span id='content'></span>
  </div>"

class window.Search
  constructor: ->
    @searchForm = $("#searchForm")
    @searchInput = $("#searchInput")
    @searchButton = $("#searchButton")
    @searchResults = $("#searchResults")

    @searchButton.click =>
      @query()
   
  query: () =>
    @clear()
    keyword = @searchInput.val()
      
    if keyword?
      $.get("/wall/search/#{stage.wallId}/#{keyword}", {},
        (res) =>
          $.each(res, (i, val) =>
            element = $(searchTemplate).appendTo(@searchResults)

            element.find("#title").html(val.title)
            element.find("#content").html(val.content)

            element.click =>
              curSheet = stage.sheets[val.id]

              if stage.activeSheet?
                stage.activeSheet.resignActive()

              wall.center(curSheet) #callback to resign selected
              curSheet.becomeActive()
          )
      )
    return


  clear: () =>
    @searchResults.html("")
