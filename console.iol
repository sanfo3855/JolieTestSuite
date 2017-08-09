
outputPort Console {
  RequestResponse: println( string )( void )
}

embedded {
  Jolie:
    "./console-imp.ol" in Console
}
