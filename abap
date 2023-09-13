TYPES: BEGIN OF ty_itab,
         flag TYPE c LENGTH 1,         " Para a seleção de linhas
         material         TYPE matnr,       " Número do Material
         material_desc    TYPE makt-maktx,  " Descrição do Material (preenchido automaticamente)
         quantity         TYPE p DECIMALS 3, " Quantidade
         centro           TYPE werks_d,     " Centro
         item_category    TYPE pstyv,       " Categoria do Item
       END OF ty_itab.

DATA: itab TYPE TABLE OF ty_itab,   " Tabela interna
      wa   TYPE ty_itab.           " Work Area



MODULE user_command_9000 INPUT.
 CASE sy-ucomm.
        WHEN 'BTN_CREATE'.
            CALL SCREEN 9100.
    ENDCASE.
ENDMODULE.


