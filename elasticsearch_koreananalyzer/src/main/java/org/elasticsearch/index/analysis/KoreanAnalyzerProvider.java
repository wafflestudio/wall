package org.elasticsearch.index.analysis;

import java.io.IOException;

import org.apache.lucene.analysis.kr.KoreanAnalyzer;
import org.elasticsearch.common.lucene.Lucene;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.index.Index;

public class KoreanAnalyzerProvider extends AbstractIndexAnalyzerProvider<KoreanAnalyzer> {

  private final KoreanAnalyzer analyzer;
  
  public KoreanAnalyzerProvider(Index index, Settings indexSettings, String name, Settings settings) throws IOException {
    super(index, indexSettings, name, settings);

    analyzer = new KoreanAnalyzer(Lucene.VERSION.LUCENE_42);
  }

  public KoreanAnalyzer get() {
    return this.analyzer;
  }
  
}