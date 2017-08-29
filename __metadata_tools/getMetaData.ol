include "console.iol"
include "metajolie.iol"
include "string_utils.iol"

main {
  rq.filename = args[0];
  rq.name.name = "";
  getMetaData@MetaJolie( rq )( metadata );
  valueToPrettyString@StringUtils( metadata )( rs );
  println@Console( rs )()
}
