/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*                                                                                    *
* Copyright (C) 2016 Claudio Guidi <guidiclaudio@gmail.com>                          *
*                                                                                    *
* Copyright (C) 2017 Matteo Sanfelici <sanfelicimatteo@gmail.com>                    *
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
*																																										 *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

include "console.iol"
include "runtime.iol"
include "file.iol"
include "string_utils.iol"
include "time.iol"

include "./__data_retriever/public/interfaces/DataRetrieverInterface.iol"
include "./public/interfaces/GoalManagerInterface.iol"
include "../public/interfaces/GoalInterface.iol"
include "../config/config.iol"

execution{ concurrent }

outputPort DataRetriever {
Interfaces: DataRetrieverInterface
}

outputPort Goal {
Interfaces: GoalInterface
}

embedded {
Jolie:
	  "./__data_retriever/main_data_retriever.ol" in DataRetriever
}

inputPort GoalManager {
Location: "local"
Protocol: sodep
Interfaces: GoalManagerInterface
}

constants {
  LOCAL_ABSTRACT_GOAL = "localAbstractGoal.iol",
  DATA_FOLDER = "data/"
}

define __delete {
  if ( filename != "" ) {
      df = filename + ".ol";
      delete@File( df )()
  }
}

init {
  initialize( request );
  global.localGUILocation = request.location;
  global.GOAL_DIRECTORY = request.goal_directory;
  global.ABSTRACT_GOAL = request.abstract_goal;
  getLocalLocation@Runtime()( global.localGoalManagerLocation );
  //println@Console("GoalManager is running...")();
  install( ExecutionFault => __delete );
  install( GoalNotFound => __delete )
}

main {
  [ goal( request )( response ) {
		for(i=0, i<global.tab, i++){
			print@Console( "   " )()
		};
	  println@Console(" TESTING " + request.name + "...")();
	  filename = "";
		checkStart = request.name;
		checkStart.prefix = "/";
		startsWith@StringUtils( checkStart )( resStartsWith );
		if( !resStartsWith ){
			global.tab++
		};
	  scope( get_goal ) {

		  install( ExecutionFault =>
							 if( !resStartsWith ){
								 global.tab--
							 };
							 for(i=0, i<global.tab, i++){
							   print@Console( "   " )()
						   };
							 println@Console(" TEST FAILED! : " + request.name )();
					     //valueToPrettyString@StringUtils( get_goal.ExecutionFault )( s );
							 for(i=0, i<global.tab, i++){
							   print@Console( "    " )()
						   };
							 if(global.tab == 0){
								 print@Console( " " )()
							 };
							 println@Console( "---" + get_goal.ExecutionFault.faultname + "---" )();
							 for(i=0, i<global.tab, i++){
							   print@Console( "    " )()
						   };
							 if(global.tab == 0){
								 print@Console( " " )()
							 };
							 println@Console( get_goal.ExecutionFault.message )();
					     throw( ExecutionFault, get_goal.ExecutionFault )
		  );
		  install( FileNotFound =>   fault.goal_name = request.name;
					    throw( GoalNotFound, fault )
		  );

		  request.client_location = global.myLocation;
		  //rd.filename = global.ABSTRACT_GOAL;
		  //println@Console( rd.filename )();
		  //readFile@File( rd )( abstract );
		  abstract = "include \"console.iol\"
			      include \"string_utils.iol\"

			      include \"./public/interfaces/GoalInterface.iol\"
			      include \"./__goal_manager/public/interfaces/GoalManagerInterface.iol\"
			      include \"./__gui/public/interfaces/GUIInterface.iol\"


			      outputPort GoalManager {
			      Protocol: sodep
			      Interfaces: GoalManagerInterface
			      }

			      outputPort GUI {
			      Protocol: sodep
			      Interfaces: GUIInterface
			      }

			      inputPort Goal {
			      Location: \"local\"
			      Protocol: sodep
			      Interfaces: GoalInterface
			      }

			      init {
				       initialize( request )() {
				          GoalManager.location = request.localGoalManagerLocation;
				          GUI.location = request.localGUILocation
				       }
			      }";
		  rd.filename = global.GOAL_DIRECTORY + request.name + ".ol";
		  readFile@File( rd )( goal );
		  rd.filename = global.GOAL_DIRECTORY + LOCAL_ABSTRACT_GOAL;
		  readFile@File( rd )( local_abstract_goal );
		  goal_activity.content = abstract + local_abstract_goal + goal;

		  filename = new;
		  with( wf ) {
		    // writing goal on file system
		    wf.filename = filename + ".ol";
		    wf.content = goal_activity.content;
		    writeFile@File( wf )( )
		  };
		  // embedding goal
		  with( request_embed ) {
		    .filepath = filename + ".ol";
		    .type = "Jolie"
		  };
		  loadEmbeddedService@Runtime( request_embed )( Goal.location );
		  with( init_activity ) {
		    .localGUILocation = global.localGUILocation;
		    .localGoalManagerLocation = global.localGoalManagerLocation
		  };
		  initialize@Goal( init_activity )();
		  if ( is_defined( request.request_message ) ) {
			run_request -> request.request_message
		  } else if ( is_defined( request.dataname ) ) {
			println@Console("Retrieving data " + global.GOAL_DIRECTORY + DATA_FOLDER + request.dataname )();
			dataretriever_rq.dataname = global.GOAL_DIRECTORY + DATA_FOLDER + request.dataname;
			getData@DataRetriever( dataretriever_rq )( run_request );
			println@Console("Data retrieved!")()
		  };
		  sleep@Time( 100 )(); // required for giving time to the embedded to prepare the run operation to receive
		  run@Goal( run_request )( response );
			if( !resStartsWith ){
					global.tab--
			};
			for(i=0, i<global.tab, i++){
				print@Console( "   " )()
			};
			println@Console(" SUCCESS: " + request.name )()

		  //println@Orchestrator("SUCCESS: " + request.name )()
	  }
  }] {
	__delete
     }
}
