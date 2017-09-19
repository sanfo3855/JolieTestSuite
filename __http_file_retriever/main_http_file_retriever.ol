/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*                                                                                    *
* Copyright (C) 2016 Claudio Guidi <guidiclaudio@gmail.com>                          *
*                                                                                    *
* Permission is hereby granted, free of charge, to any person obtaining a copy of    *
* this software and associated documentation files (the "Software"), to deal in the  *
* Software without restriction, including without limitation the rights to use,      *
* copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the    *
* Software, and to permit persons to whom the Software is furnished to do so, subject*
* to the following conditions:                                                       *
*                                                                                    *
* The above copyright notice and this permission notice shall be included in all     *
* copies or substantial portions of the Software.                                    *
*                                                                                    *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,*
* INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A      *
* PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT *
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION  *
* OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     *
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                             *
*                                                                                    *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

include "./public/interfaces/HttpFileRetrieverInterface.iol"

include "console.iol"
include "string_utils.iol"
include "file.iol"

include "../config/config.iol"


execution{ concurrent }

inputPort HttpFileRetrieverLocal {
  Location: "local"
  Interfaces: HttpFileRetrieverInterface
}

inputPort HttpFileRetriever {
  Location: HttpFileRetrieverLocation
  Protocol: http {
		    .keepAlive = 0; // Do not keep connections open
		    .debug = 0;
		    .debug.showContent = 0;
		    .format -> format;
		    .contentType -> mime;
		    .default = "default"
		  }
  Interfaces: HttpFileRetrieverInterface
}


define setMime {
	getMimeType@File( file.filename )( mime );
	//println@Console( file.filename +":" + mime )();
	mime.regex = "/";
	split@StringUtils( mime )( s );
	if ( s.result[0] == "text" ) {
		file.format = "text";
		format = "html"
	} else {
		file.format = format = "binary"
	}
}


init{
  initialize( request );
  documentRootDirectory = request.documentRootDirectory
}

main {

  default( request )( response ) {
    scope( s ) {
	//valueToPrettyString@StringUtils( request )( str );
	//println@Console( str )();
	install( FileNotFound => println@Console("File not found: " + request.operation )()
	);
	s = request.operation;
	s.regex = "\\?";
	split@StringUtils( s )( s );
	filename = s.result[0];	// used for retrieving css files within fault handler
	file.filename = documentRootDirectory + s.result[0];
	setMime;
	readFile@File( file )( response )
	//valueToPrettyString@StringUtils( response )( str );
	//println@Console( str )()
    }
  }

}
