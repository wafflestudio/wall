Infinite Wall
=====================

#### Motto

- 인간의 사고를 확장하는 도구.

#### 데이터베이스 스키마 마이그레이션  

    $ play console
    scala> Environment.activateSqueryl()
    scala> Environment.createSchema()  # schema 만들때
    scala> Environment.dropSchema()   # schema 지울때
    ^D

#### 자동 컴파일 및 실행
    $ play 
    [Infinite Wall] $ compile 
    [Infinite Wall] $ ~run