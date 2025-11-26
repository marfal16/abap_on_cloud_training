CLASS lhc_zr_biglietto_fm_2 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Biglietto
        RESULT result,
      earlynumbering_create FOR NUMBERING
        IMPORTING entities FOR CREATE Biglietto.
ENDCLASS.

CLASS lhc_zr_biglietto_fm_2 IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD earlynumbering_create.
    DATA: lv_id TYPE zr_biglietto_fm_2-IdBiglietto.

* Primo metodo per recuperare valore max
*    SELECT MAX( Idbiglietto )
*    FROM zr_biglietto_fm_2
*    INTO @DATA(lv_max).

* Secondo metodo per recuperare valore max
    WITH +big AS (
            SELECT MAX( Idbiglietto ) AS id_max
                FROM zr_biglietto_fm_2
            UNION
            SELECT MAX( Idbiglietto ) AS id_max
                FROM zbglietto_fm_2_d
            )
            SELECT MAX( id_max )
                FROM +big AS big
                INTO @DATA(lv_max).

    LOOP AT entities INTO DATA(ls_entity).
      IF ls_entity-IdBiglietto IS INITIAL.

* Terzo metodo per recuperare valore max da range numerazione
*      try.

*        cl_numberrange_runtime=>number_get(
*          EXPORTING
*            ignore_buffer     = 'X'
*            nr_range_nr       = '01'
*            object            = 'ZID_BIG_NR'
**          quantity          =
**          subobject         =
**          toyear            =
*          IMPORTING
*            number            = DATA(lv_max)
**          returncode        =
**          returned_quantity =
*        ).

*      CATCH cx_nr_object_not_found.
*      CATCH cx_number_ranges.

        lv_max += 1. "commentato perché ora recuperiamo dal range num.
        lv_id = lv_max.
      ELSE.
        lv_id = ls_entity-IdBiglietto.
      ENDIF.
*      ENTRY.

      APPEND VALUE #( %cid = ls_entity-%cid
      %is_draft = ls_entity-%is_draft
      IdBiglietto = lv_id
      )
      TO mapped-biglietto.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
