include "metajolie.iol"
include "string_utils.iol"
include "console.iol"
include "metaparser.iol"
include "file.iol"

define __getCustomOutputPort
{
  for(i=0, i< #metadata.output, i++){
    if( metadata.output[i].location[0] != "local"){
      println@Console( "Found Custom OutputPort " + i + ": " + metadata.output[i].name[0].name[0] )();
      customOutput[j++] << metadata.output[i]
    }
  };
  j=0;
  println@Console( "\n  " )()
}

define __getCustomInterfaces
{
  for(i=0, i<#metadata.interfaces, i++){
    for(k=0, k<#customOutput, k++){
      if(metadata.interfaces[i].name[0].name[0] == customOutput[k].interfaces[0].name[0].name[0]){
        println@Console( "Found Custom Interface " + i + ": " + metadata.interfaces[i].name[0].name[0] )();
        customInterfaces[j++] << metadata.interfaces[i]
      }
    }
  };
  j=0;
  println@Console( "\n  " )()
}

define __getTypes
{
  for ( i=0, i<#metadata.types, i++ ) {
    typesList[i] << metadata.types[i]
  }
}

define __composeFiles
{
  for ( i=0, i<#customOutput, i++ ) {
    depFile.filename = customOutput[i].name[0].name[0] + ".depservice";
    content = "";
    //println@Console( "\n---------------------------------------\n------------- " + depFile.filename + " -------------\n---------------------------------------\n" )();
    for( j=0, j<#customOutput[i].interfaces, j++ ) {
      for( k=0, k<#customInterfaces, k++ ) {
        if(customOutput[i].interfaces[j].name[0].name[0] == customInterfaces[k].name[0].name[0] ){
          iface.name.name = customInterfaces[k].name[0].name[0];
          iface.operations << customInterfaces[k].operations;
          iface.types << typesList;
          getInterface@Parser( iface )( intf );
          content = content + intf
        }
      }
    };
    content = content + "\ninputPort " + customOutput[i].name[0].name[0] + " {";
    content = content + "\nLocation: \"" + customOutput[i].location[0] + "\"";
    content = content + "\nProtocol: " + customOutput[i].protocol[0];
    content = content + "\nInterfaces:";
    for( j=0, j<#customOutput[i].interfaces, j++){
      content = content + " " + customOutput[i].interfaces[j].name[0].name[0];
      if( j != #customOutput[i].interfaces-1 ){
        content = content + ","
      }
    };
    content = content + "\n}";
    depFile.content = content;
    writeFile@File( depFile )( )
  }
}

main
{
  rq.filename = args[0];
  rq.name.name = "";
  getMetaData@MetaJolie( rq )( metadata );

  __getCustomOutputPort;
  __getCustomInterfaces;
  __getTypes;

  __composeFiles

}
