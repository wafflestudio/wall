package org.elasticsearch.index.analysis;

import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.kr.KoreanFilter;
import org.elasticsearch.common.inject.Inject;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.index.Index;

public class KoreanTokenFilterFactory extends AbstractTokenFilterFactory {

  @Inject
  public KoreanTokenFilterFactory(Index index, Settings indexSettings, String name, Settings settings) {
    super(index, indexSettings, name, settings);
  }
  @Override
  public TokenStream create(TokenStream tokenStream) {
    return new KoreanFilter(tokenStream);
  }
  
}