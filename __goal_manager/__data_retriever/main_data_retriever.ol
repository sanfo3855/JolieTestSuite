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

include "./public/interfaces/DataRetrieverInterface.iol"
include "./public/interfaces/DataFileInterface.iol"

include "file.iol"
include "runtime.iol"
include "time.iol"
include "console.iol"

execution{ concurrent }

outputPort DataFile {
Interfaces: DataFileInterface
}

inputPort DataRetriever {
Location: "local"
Interfaces: DataRetrieverInterface
}

main {
      getData( request )( response ) {
	    rd.filename = request.dataname;
	    readFile@File( rd )( datafile );

	    // create datafile
	    content = "include \"./__goal_manager/__data_retriever/public/interfaces/DataFileInterface.iol\"\ninputPort DataRetriever { Location:\"local\"\nInterfaces: DataFileInterface }\n";
	    content = content + "init {" + datafile + "}\nmain { getData()( request ) { nullProcess } }";

	    filename = new;
	    with( wf ) {
		  .filename = filename + ".ol";
		  .content -> content
	    };
	    writeFile@File( wf )();

	    // embed it
	    with( request_embed ) {
	      .filepath = filename + ".ol";
	      .type = "Jolie"
	    };
	    loadEmbeddedService@Runtime( request_embed )( DataFile.location );

	    // retrieve data
	    sleep@Time( 200 )(); // in order to give time to the embedded file to be ready to receive
	    getData@DataFile()( response );

	    // delete tmp file
	    delete@File( wf.filename )()
      }
}
