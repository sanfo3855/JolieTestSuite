

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

outputPort Orchestrator {
Location: "socket://localhost:10000"
Protocol: sodep
RequestResponse: println( string )( void )
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
  println@Console("GoalManager is running...")();
  install( ExecutionFault => __delete );
  install( GoalNotFound => __delete )
}

main {
  [ goal( request )( response ) {
	  println@Console("TESTING " + request.name + "...")();
	  filename = "";
	  scope( get_goal ) {

		  install( ExecutionFault => println@Orchestrator("TEST FAILED! : " + request.name )();
					     valueToPrettyString@StringUtils( get_goal.ExecutionFault )( s );
					     println@Orchestrator( s )();
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
		  println@Orchestrator("SUCCESS: " + request.name )()
	  }
  }] {
	__delete
     }
}
