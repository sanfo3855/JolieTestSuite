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

include "./public/interfaces/TestSuiteClientGenerationInterface.iol"
include "console.iol"

outputPort ClientGenerator {
Interfaces: TestSuiteClientGenerationInterface
}

embedded {
Jolie :
    "main_clients_generator.ol" in ClientGenerator
}

main {
      if( #args == 3 ) {
	  request.main_file = args[ 0 ];
	  request.target_folder = args[ 1 ];
	  request.http_test_suite_location = "http://localhost:55555/";
	  if ( args[ 2 ] == "yes" ) {
		request.generate_data = true
	  } else {
		request.generate_data = false
	  };
	  generate@ClientGenerator( request )()
      } else {
	  println@Console("Usage jolie generate_clients.ol sourcefile target_folder generate_data (yes/no)")()
      }
}
