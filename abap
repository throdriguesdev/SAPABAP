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

TYPES: BEGIN OF ty_item,
         material      TYPE matnr,
         quantity      TYPE p DECIMALS 3,
         centro        TYPE werks_d,
         item_category TYPE pstyv,
       END OF ty_item.

DATA:
  p_auart  TYPE vbak-auart,
  p_vkorg  TYPE vbak-vkorg,
  p_vtweg  TYPE vbak-vtweg,
  p_spart  TYPE vbak-spart,
  p_kunnr  TYPE vbak-kunnr,
  p_kunnr2 TYPE vbak-kunnr.

DATA: it_items TYPE TABLE OF ty_item,
      wa_item  TYPE ty_item.

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
      filename                = v_file
    TABLES
      data_tab                = it_data
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
    MESSAGE 'Erro ao carregar o arquivo.' TYPE 'E'.
  ENDIF.

LOOP AT it_data INTO wa_data.
    SPLIT wa_data AT ';' INTO ident var1 var2 var3 var4 var5 var6.

    CASE ident.
      WHEN 'H'.
        " Atribuindo valores de cabeçalho
        p_auart = var1.
        p_vkorg = var2.
        p_vtweg = var3.
        p_spart = var4.
        p_kunnr = var5.
        p_kunnr2 = var6.

      WHEN 'IT'.
        wa_item-material = var1.
        wa_item-quantity = var2.
        wa_item-centro = var3.
        wa_item-item_category = var4.

        APPEND wa_item TO it_items.
        CLEAR wa_item.


    ENDCASE.

ENDLOOP.



