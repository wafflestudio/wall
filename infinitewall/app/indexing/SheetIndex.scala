package indexing

import play.api.libs.json._
import play.api.Logger
import com.github.cleverage.elasticsearch.ScalaHelpers._
import org.elasticsearch.index.query.{QueryBuilders, QueryBuilder}
import org.elasticsearch.action.index.IndexResponse

case class SheetIndex(id: String, val wallId: String, var title: String, var content: String) extends Indexable

object SheetIndexManager extends IndexableManager[SheetIndex] { 
  val indexType = "SheetIndex"
  val reads: Reads[SheetIndex] = Json.reads[SheetIndex]
  val writes: Writes[SheetIndex] = Json.writes[SheetIndex]

  //Sheet Index
  def create(id: Long, wallId: Long, title: String, content: String) = {
    val sheetIndex = SheetIndex(id.toString(), wallId.toString(), title, content)
    val sheetIndexResponse: IndexResponse = SheetIndexManager.index(sheetIndex)

    Logger.info("SheetIndexManager.index() : " + sheetIndex)
  }

  def setTitle(id: Long, title: String) = {
    var sheetIndex = SheetIndexManager.get(id.toString())
    sheetIndex match { 
      case Some(si: SheetIndex) =>
        si.title = title
        SheetIndexManager.index(si)
        Logger.info("SheetIndexManager.index() / updateTitle : " + title)
      case None => None
        Logger.info("SheetIndexManager.index() / updateTitle : ERROR(No Index)")
    }
  }

  def setText(id: Long, content:String) = {
    var sheetIndex = SheetIndexManager.get(id.toString())
    sheetIndex match { 
      case Some(si: SheetIndex) =>
        si.content = content
        SheetIndexManager.index(si)
        Logger.info("SheetIndexManager.index() / updateContent : " + content)
      case None => None
        Logger.info("SheetIndexManager.index() / updateContent : ERROR(No Index)")
    }
  }

  //Sheet Index Retreival
  //Overloading ScalaHelpers` search method
  def search(wallId: Long, keyword: String): List[SheetIndex] = {
    val indexQuery = IndexQuery[SheetIndex]().withBuilder(QueryBuilders.multiMatchQuery(keyword, "title", "content"))
    val indexResults: IndexResults[SheetIndex] = SheetIndexManager.search(indexQuery)

    Logger.info("SheetIndexManager.search() / multiQuery : " + indexResults.results)
    indexResults.results
  }
}
