type GoalNotFoundType: void {
      .goal_name: string
}

type GoalRequest: void {
      .name: string
      .request_message?: undefined
      .dataname?: string
      .enableFault?: bool
}

type InitializeRequest: void {
      .location: any
      .goal_directory: string
      .abstract_goal: string
}

interface GoalManagerInterface {
OneWay:
      initialize( InitializeRequest )
RequestResponse:
      /*
      *	Refinement
      */
      goal( GoalRequest )( undefined )
	throws ExecutionFault
	       GoalNotFound( GoalNotFoundType )
}
