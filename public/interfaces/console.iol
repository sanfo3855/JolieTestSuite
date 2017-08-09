
outputPort Console {
  RequestResponse: println( string )( void )
}

embedded {
  Jolie:
    "console-imp.iol" in Console
}
