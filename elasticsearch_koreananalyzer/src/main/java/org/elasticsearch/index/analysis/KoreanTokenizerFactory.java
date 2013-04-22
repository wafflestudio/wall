package org.elasticsearch.index.analysis;

import java.io.Reader;

import org.apache.lucene.analysis.Tokenizer;
import org.apache.lucene.analysis.kr.KoreanTokenizer;
import org.elasticsearch.common.inject.Inject;
import org.elasticsearch.common.lucene.Lucene;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.index.Index;

public class KoreanTokenizerFactory extends AbstractTokenizerFactory {

  @Inject
  public KoreanTokenizerFactory(Index index, Settings indexSettings, String name, Settings settings) {
    super(index, indexSettings, name, settings);
  }

  public Tokenizer create(Reader reader) {
    return new KoreanTokenizer(Lucene.VERSION.LUCENE_42, reader);
  }
  
}