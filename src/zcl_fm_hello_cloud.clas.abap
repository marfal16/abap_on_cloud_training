CLASS zcl_fm_hello_cloud DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_fm_hello_cloud IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  out->write( 'Hello World!' ).
  out->write( 'Ciao').

  ENDMETHOD.
ENDCLASS.
