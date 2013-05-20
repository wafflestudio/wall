package indexing

import play.api.libs.json._
import play.api.Logger
import com.github.cleverage.elasticsearch.ScalaHelpers._
import org.elasticsearch.index.query.{QueryBuilders, QueryBuilder}
import org.elasticsearch.action.index.IndexResponse

case class SheetIndex(id: String, val wallId: String, var title: String, var content: String) extends Indexable

object SheetIndexManager extends IndexableManager[SheetIndex] { 
  val indexType = "SheetIndex"
  implicit val reads: Reads[SheetIndex] = Json.reads[SheetIndex]
  implicit val writes: Writes[SheetIndex] = Json.writes[SheetIndex]

  //Sheet Index
  def create(id: String, wallId: String, title: String, content: String) = if(!play.Play.isTest) {
    val sheetIndex = SheetIndex(id, wallId, title, content)
    val sheetIndexResponse: IndexResponse = SheetIndexManager.index(sheetIndex)

    Logger.info("SheetIndexManager.index() : " + sheetIndex)
  }

  def setTitle(id: String, title: String) = if(!play.Play.isTest) {
    var sheetIndex = SheetIndexManager.get(id)
    sheetIndex match { 
      case Some(si: SheetIndex) =>
        si.title = title
        SheetIndexManager.index(si)
        Logger.info("SheetIndexManager.index() / updateTitle : " + title)
      case None => None
        Logger.info("SheetIndexManager.index() / updateTitle : ERROR(No Index)")
    }
  }

  def setText(id: String, content:String) = if(!play.Play.isTest) {
    var sheetIndex = SheetIndexManager.get(id)
    sheetIndex match { 
      case Some(si: SheetIndex) =>
        si.content = content
        SheetIndexManager.index(si)
        Logger.info("SheetIndexManager.index() / updateContent : " + content)
      case None => None
        Logger.info("SheetIndexManager.index() / updateContent : ERROR(No Index)")
    }
  }

  def remove(id: String) = if(!play.Play.isTest) {
    var deleteRes = SheetIndexManager.delete(id)
    Logger.info("SheetIndexManager.remove() : " + id + " / " + deleteRes)
  }

  //Sheet Index Retreival
  //Overloading ScalaHelpers` search method
  def search(wallId: String, keyword: String): List[JsValue] = {
    if(!play.Play.isTest)
    {
      val indexQuery = IndexQuery[SheetIndex]().withBuilder(QueryBuilders.boolQuery().must(QueryBuilders.matchQuery("wallId", wallId)).must(QueryBuilders.termQuery("wallId", wallId)))
      val indexResults: IndexResults[SheetIndex] = SheetIndexManager.search(indexQuery)
  
      Logger.info("SheetIndexManager.search() / multiQuery : " + indexResults.results)
      val jsonResults = indexResults.results.map { t:SheetIndex =>
        Json.toJson(t)
      }
      jsonResults
    }
    else
      List()
  }
}
