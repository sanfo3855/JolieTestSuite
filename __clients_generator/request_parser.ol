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

include "./public/interfaces/RequestParserInterface.iol"

include "runtime.iol"
include "string_utils.iol"
include "console.iol"

execution{ concurrent }

outputPort MySelf {
Interfaces: RequestParserInterface
}

inputPort RequestParserInterface {
Location: "local"
Interfaces: RequestParserInterface
}

constants {
    SAMPLE_INT = "42",
    SAMPLE_DOUBLE = "42.42",
    SAMPLE_LONG = "123456789",
    SAMPLE_MAX = 5,
    SAMPLE_BOOL = "true",
    SAMPLE_STRING = "\"string\"",
    NESTED_DEPTH = 10 // avoiding infinte tree due to recursive types
}

init {
    getLocalLocation@Runtime()( MySelf.location )
}

main {
    [ getRequest( request )( response ) {
	  /*rq << request;
	  undef ( rq.types );
	  valueToPrettyString@StringUtils( request )( s );
	  println@Console("GetRequest: " + s )();*/
	  // preparing hash table
	  for( t = 0, t < #request.types, t++ ) {
		type_hashmap.( request.types[ t ].name.name ) << request.types[ t ]
	  };
	  if ( is_defined( type_hashmap.( request.request_type_name ) ) ) {
		with( req ) {
		    .type_name = request.request_type_name;
		    .node_name = "request";
		    .type_hashmap -> type_hashmap;
		    .is_inline = false;
		    .nested_level = 1
		};
		getType@MySelf( req )( res );
		for( r = 0, r < #res.rows, r++ ) {
		    response.rows[ #response.rows ] = res.rows[ r ]
		}
	  }
    }] { nullProcess }

    [ getNativeType( request )( response ) {
	  //valueToPrettyString@StringUtils( request.native_type )( s );
	  //println@Console("GetNativeType: " + s )();
	  resp = request.node_name + "=";
	  if ( is_defined( request.native_type.string_type ) ) {
		response.rows[ 0 ] = resp + SAMPLE_STRING
	  } else if ( is_defined( request.native_type.int_type ) ) {
		response.rows[ 0 ] =  resp + SAMPLE_INT
	  } else if ( is_defined( request.native_type.is_void ) ) {
		response.rows[ 0 ] = ""
	  } else if ( is_defined( request.native_type.double_type ) ) {
		response.rows[ 0 ] = resp + SAMPLE_DOUBLE
	  } else if ( is_defined( request.native_type.any_type ) ) {
		response.rows[ 0 ] = resp + SAMPLE_ANY
	  } else if ( is_defined( request.native_type.link ) ) {
		with( req ) {
		    .type_name = request.native_type.link.name;
		    .node_name = request.node_name;
		    .type_hashmap -> request.type_hashmap;
		    .is_inline = false;
		    .nested_level = request.nested_level + 1
		};
		getType@MySelf( req )( res );
		for( r = 0, r < #res.rows, r++ ) {
		    response.rows[ #response.rows ] = res.rows[ r ]
		}
	  } else if ( is_defined( request.native_type.bool_type ) ) {
		response.rows[ 0 ] = resp + SAMPLE_BOOL
	  } else if ( is_defined( request.native_type.long_type ) ) {
		response.rows[ 0 ] = resp + SAMPLE_LONG
	  }
	 //;println@Console( response.rows[ 0 ] )()
    }] { nullProcess }

    [ getType( request )( response ) {
	 // valueToPrettyString@StringUtils( request )( s );
	 // println@Console("GetType: " + s )();
	  if ( request.nested_level < NESTED_DEPTH ) {
		if ( request.is_inline ) {
		      current_type << request.is_inline.inline_type
		} else {
		      current_type << request.type_hashmap.( request.type_name )
		};
		// root

		if ( request.type_name == "undefined" ) {
			response.rows[ 0 ] = request.node_name + "=\"\""
		} else {
			with( req ) {
				.native_type << current_type.root_type;
				.node_name = request.node_name;
				.type_hashmap -> request.type_hashmap;
				.nested_level = request.nested_level + 1
			};
			getNativeType@MySelf( req )( response )
		}
		;
		// subtypes
		for( st = 0, st < #current_type.sub_type, st++ ) {
		    undef( req );
		    with( req ) {
			.subtype -> current_type.sub_type[ st ];
			.node_name = request.node_name;
			.type_hashmap -> request.type_hashmap;
			.nested_level = request.nested_level + 1
		    };
		    getSubType@MySelf( req )( res );
		    for( r = 0, r < #res.rows, r++ ) {
			  response.rows[ #response.rows ] = res.rows[ r ]
		    }
		}
	  }
    }] { nullProcess }

    [ getSubType( request )( response ) {
	  //valueToPrettyString@StringUtils( request.subtype )( s );
	  //println@Console("GetSubType: " + request.node_name )();
	  if ( request.nested_level < NESTED_DEPTH ) {
		cur_node_name = request.node_name + "." + request.subtype.name;
		min = request.subtype.cardinality.min;
		if ( is_defined( request.subtype.cardinality.infinite ) ) {
		      max = SAMPLE_MAX
		} else if ( request.subtype.cardinality.min >= SAMPLE_MAX ) {
		      max = min
		} else if ( request.subtype.cardinality.max >= SAMPLE_MAX ) {
		      max = SAMPLE_MAX
		} else {
		      max = request.subtype.cardinality.max
		};
		//println@Console( max )();
		for( index = 0, index < max, index++ ) {
		      //println@Console("index " + index )();
		      undef( is_inline );
		      if ( is_defined( request.subtype.type_inline ) ) {
			    is_inline = true;
			    is_inline.inline_type << request.subtype.type_inline;
			    type_name = request.subtype.type_inline.name.name
		      } else {
			    is_inline = false;
			    type_name = request.subtype.type_link.name
		      };
		      with( req ) {
			  .is_inline -> is_inline;
			  .type_name = type_name;
			  .node_name = cur_node_name + "[" + index + "]";
			  .type_hashmap -> request.type_hashmap;
			  .nested_level = request.nested_level + 1
		      };
		      getType@MySelf( req )( res );
		      for( r = 0, r < #res.rows, r++ ) {
			  response.rows[ #response.rows ] = res.rows[ r ]
		      }
		}
	  }
    }] { nullProcess }
}
