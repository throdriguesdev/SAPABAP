  REPORT zre12al22_vendamass.


PARAMETERS: p_file TYPE localfile.

DATA: it_data TYPE TABLE OF string,
      wa_data TYPE string,
      v_file  TYPE string,
      ident   TYPE string,
      var1    TYPE string,
      var2    TYPE string,
      var3    TYPE string,
      var4    TYPE string,
      var5    TYPE string,
      var6    TYPE string.

DATA: header LIKE bapisdhead1,
      item    LIKE bapisditem OCCURS 0 WITH HEADER LINE,
      partner LIKE bapipartnr OCCURS 0 WITH HEADER LINE,
      return  LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
      lt_schedules_in TYPE TABLE OF bapischdl,
      lt_schedules_inx TYPE TABLE OF bapischdlx,
      wa_schedule_in TYPE bapischdl,
      wa_schedule_inx TYPE bapischdlx,
      lv_itnum TYPE vbeln_vl,
      lv_error_occurred TYPE abap_bool,
      wa_return TYPE bapiret2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      field_name = p_file
    CHANGING
      file_name  = p_file.
  IF sy-subrc <> 0.
    MESSAGE 'Erro ao selecionar o arquivo.' TYPE 'E'.
  ENDIF.

START-OF-SELECTION.

  v_file = p_file.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename = v_file
    TABLES
      data_tab = it_data.
  IF sy-subrc <> 0.
    MESSAGE 'Erro ao carregar o arquivo.' TYPE 'E'.
    EXIT.
  ENDIF.

  LOOP AT it_data INTO wa_data.
    SPLIT wa_data AT ';' INTO ident var1 var2 var3 var4 var5 var6.
IF ident = 'H' AND var1 IS INITIAL.
   MESSAGE 'O tipo de documento de venda está faltando no arquivo!' TYPE 'E'.
   EXIT.
ENDIF.

   CASE ident.
      WHEN 'H'.
        IF NOT header-doc_type IS INITIAL.
          PERFORM create_sales_order.
          CLEAR: header, partner.
          REFRESH: item, lt_schedules_in, lt_schedules_inx, partner.
        ENDIF.

        header-doc_type   = var1.
        header-sales_org  = var2.
        header-distr_chan = var3.
        header-division   = var4.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = var5
          IMPORTING
            OUTPUT = var5.

        partner-partn_role = 'AG'.
        partner-partn_numb = var5.
        APPEND partner.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = var6
          IMPORTING
            OUTPUT = var6.

        partner-partn_role = 'WE'.
        partner-partn_numb = var6.
        APPEND partner.

      WHEN 'IT'.
        IF lv_itnum IS INITIAL.
          lv_itnum = '000010'.
        ELSE.
          ADD 10 TO lv_itnum.
        ENDIF.

        CLEAR item.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = var1
          IMPORTING
            OUTPUT = var1.

        item-itm_number = lv_itnum.
        item-material = var1.
        item-target_qty = var2.
        item-plant = var3.
        item-item_categ = var4.

        APPEND item TO item.

        CLEAR: wa_schedule_in, wa_schedule_inx.
        wa_schedule_in-itm_number = lv_itnum.
        wa_schedule_in-sched_line = '0001'.
        wa_schedule_in-req_qty = var2.
        APPEND wa_schedule_in TO lt_schedules_in.

        wa_schedule_inx-itm_number = lv_itnum.
        wa_schedule_inx-sched_line = '0001'.
        wa_schedule_inx-req_qty = 'X'.
        APPEND wa_schedule_inx TO lt_schedules_inx.
    ENDCASE.
  ENDLOOP.

    "Chamar a BAPI após cada cabeçalho e seus itens
    IF ident = 'H' AND sy-tabix > 1.
      PERFORM create_sales_order.
    ENDIF.


  "Para o último conjunto de cabeçalho e itens
  PERFORM create_sales_order.

  FORM create_sales_order.
    CALL FUNCTION 'BAPI_SALESDOCU_CREATEFROMDATA1'
      EXPORTING
        sales_header_in = header
      TABLES
        return = return
        sales_items_in = item
        sales_schedules_in = lt_schedules_in
        sales_schedules_inx = lt_schedules_inx
        sales_partners = partner.

    LOOP AT return INTO wa_return.
      CASE wa_return-type.
        WHEN 'E'.
          lv_error_occurred = abap_true.
          WRITE: / wa_return-message.
        WHEN 'W'.
          WRITE: / wa_return-message.
      ENDCASE.
    ENDLOOP.

    IF lv_error_occurred = abap_true.
      EXIT.
    ELSEIF NOT wa_return-type = 'E'.
      COMMIT WORK AND WAIT.
      WRITE: / 'Documento de Venda criado com o número:', wa_return-id.
    ENDIF.
  ENDFORM.
