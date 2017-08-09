

inputPort LocalIn {
Location: "local"
RequestResponse: println( string )( void )
}

outputPort Orchestrator {
Location: "socket://172.17.0.1:10000"
Protocol: sodep
RequestResponse: println( string )( void )
}

execution{ concurrent }

main
{
  [println ( request )( response ){
    println@Orchestrator( request )( )
  }]
}
