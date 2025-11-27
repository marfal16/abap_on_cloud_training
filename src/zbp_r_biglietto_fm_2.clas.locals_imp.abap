CLASS lhc_zr_biglietto_fm_2 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Biglietto
        RESULT result,
      earlynumbering_create FOR NUMBERING
        IMPORTING entities FOR CREATE Biglietto,

      checkStatus FOR VALIDATE ON SAVE
        IMPORTING keys FOR Biglietto~CheckStatus,
      GetDefaultsForCreate FOR READ
        IMPORTING keys FOR FUNCTION Biglietto~GetDefaultsForCreate RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR Biglietto RESULT result,
      onSave FOR DETERMINE ON SAVE
        IMPORTING keys FOR Biglietto~onSave,
      CustomDelete FOR MODIFY
        IMPORTING keys FOR ACTION Biglietto~CustomDelete RESULT result.


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

        lv_max += 1.
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

  METHOD checkStatus.
    DATA: lt_biglietto TYPE TABLE FOR READ RESULT zr_biglietto_fm_2.
    READ ENTITIES OF zr_biglietto_fm_2
    IN LOCAL MODE
    ENTITY Biglietto
    FIELDS (  Stato )
    WITH CORRESPONDING #( keys )
    RESULT lt_biglietto.
    LOOP AT lt_biglietto INTO DATA(ls_biglietto)
    WHERE stato <> 'BOZZA' AND stato <> 'FINALE' AND stato <> 'CANC'.
      APPEND VALUE #(
      %tky = ls_biglietto-%tky  )
      TO failed-biglietto.

      APPEND VALUE #(
        %tky = ls_biglietto-%tky
        %msg = NEW zcx_err_bigl_1(
                  textid  = zcx_err_bigl_1=>gc_invalid
                  severity = if_abap_behv_message=>severity-error
               )
        %element-Stato = if_abap_behv=>mk-on
      ) TO reported-biglietto.

    ENDLOOP.
  ENDMETHOD.

  METHOD GetDefaultsForCreate.
    result = VALUE #( FOR key IN keys (
           %cid = key-%cid
           %param-stato = 'BOZZA'
            ) ).
  ENDMETHOD.


  METHOD get_instance_features.
    DATA: ls_res LIKE LINE OF result.
    READ ENTITIES OF zr_biglietto_fm_2
       IN LOCAL MODE
       ENTITY Biglietto
       FIELDS (  Stato )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_result) .
    LOOP AT lt_result INTO DATA(ls_result).
      CLEAR ls_res.
      ls_res-%tky = ls_result-%tky.
      ls_res-%field-Stato = if_abap_behv=>fc-f-read_only.
      ls_res-%action-CustomDelete =
      COND #( WHEN ls_result-Stato = 'FINALE'
      THEN if_abap_behv=>fc-o-enabled
      ELSE if_abap_behv=>fc-o-disabled ).

      APPEND ls_res TO result.
*      APPEND VALUE #(
*  %tky = ls_result-%tky
*  %field-Stato = if_abap_behv=>fc-f-read_only )
*  TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD onSave.
    READ ENTITIES OF zr_biglietto_fm_2
       IN LOCAL MODE
       ENTITY Biglietto
       FIELDS (  Stato )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_result) .
    LOOP AT lt_result INTO DATA(ls_result)
    WHERE stato = 'BOZZA'.
      MODIFY ENTITIES OF zr_biglietto_fm_2
      IN LOCAL MODE ENTITY Biglietto
      UPDATE FROM VALUE #(  (
      %tky = ls_result-%tky
      Stato = 'FINALE'
      %control-Stato = if_abap_behv=>mk-on
      )
      ).

    ENDLOOP.
  ENDMETHOD.

  METHOD CustomDelete.
    DATA:
      lt_biglietto TYPE TABLE FOR READ RESULT zr_biglietto_fm_2.

    READ ENTITIES OF zr_biglietto_fm_2 IN LOCAL MODE
    ENTITY Biglietto
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT lt_biglietto.
    LOOP AT lt_biglietto INTO DATA(ls_biglietto).
      MODIFY ENTITIES OF zr_biglietto_fm_2 IN LOCAL MODE
             ENTITY Biglietto
             UPDATE FROM VALUE #( ( %tky               = ls_biglietto-%tky
                                    Stato             = 'CANC'
                                    %control-Stato = if_abap_behv=>mk-on ) ).
      ls_biglietto-stato = 'CANC'.
      INSERT VALUE #( %tky = ls_biglietto-%tky
                     %param = ls_biglietto ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
