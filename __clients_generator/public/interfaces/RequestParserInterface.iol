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

include "types/role_types.iol"

type GetRequestRequest: void {
      .types*: Type
      .request_type_name: string
}

type RowsResponse: void {
      .rows*: string
}

type GetNativeTypeRequest: void {
      .native_type: NativeType
      .node_name: string
      .nested_level: int
      .type_hashmap: undefined
}

type GetTypeRequest: void {
      .is_inline: bool {
	    .inline_type?: Type
      }
      .type_name: string
      .node_name: string
      .nested_level: int
      .type_hashmap: undefined
}

type GetSubTypeRequest: void {
      .subtype: SubType
      .node_name: string
      .nested_level: int
      .type_hashmap: undefined
}

interface RequestParserInterface {
RequestResponse:
      getRequest( GetRequestRequest )( RowsResponse ),
      getNativeType( GetNativeTypeRequest )( RowsResponse ),
      getType( GetTypeRequest )( RowsResponse ),
      getSubType( GetSubTypeRequest )( RowsResponse )
}
