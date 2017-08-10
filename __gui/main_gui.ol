

include "console.iol"
include "ui/swing_ui.iol"

include "./public/interfaces/GUIInterface.iol"

execution{ concurrent }

inputPort GUI {
Location: "local"
Protocol: sodep
Interfaces: GUIInterface
}

init {
  //println@Console("GUI is running...")()
}

main {
  [ getInfo( request )( response ) {
    for ( i = 0, i < #request.field, i++ ) {
      showInputDialog@SwingUI( request.field[ i ].message )( value );
      with( response.field[ i ] ) {
	.name = request.field[ i ].name;
	.value = value
      }
    }
  }] { nullProcess }

  [ showMsg( request )( response ) {
    showMessageDialog@SwingUI( request.message )()
  }] { nullProcess }
}
