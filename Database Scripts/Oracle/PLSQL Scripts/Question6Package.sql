CREATE OR REPLACE PACKAGE inv_ctl_pkg AS

  FUNCTION CALC_ORDER_TOTAL (o_id_in IN orders.o_id%TYPE) RETURN NUMBER;
  PROCEDURE ORDER_PLACED (c_id IN customer.c_id%TYPE, method_pmt IN orders.o_methpmt%TYPE, os_id IN orders.os_id%TYPE);
  PROCEDURE ORDER_PLACED (c_last_in IN customer.c_last%TYPE, c_first_in IN customer.c_first%TYPE, method_pmt IN orders.o_methpmt%TYPE, os_id IN orders.os_id%TYPE);
  PROCEDURE INVENTORY_ORDERED (o_id_in IN order_line.o_id%TYPE, inv_id_in IN order_line.inv_id%TYPE, ol_quantity_in IN order_line.ol_quantity%TYPE);
  PROCEDURE CHANGED_MY_MIND (o_id_in IN order_line.o_id%TYPE, inv_id_in IN order_line.inv_id%TYPE, ol_quantity_in IN order_line.ol_quantity%TYPE);
  PROCEDURE SHIPMENT_RECEIVED (ship_id_in shipment_line.ship_id%TYPE, inv_id_in shipment_line.inv_id%TYPE, arrival SYSDATE);
  PROCEDURE SHIPMENT_RECEIVED (ship_id_in shipment_line.ship_id%TYPE, inv_id_in shipment_line.inv_id%TYPE, sl_quantity_in shipment_line.sl_quantity%TYPE, arrival SYSDATE);
  PROCEDURE SHIPMENT_RECEIVED (ship_id_in shipment_line.ship_id%TYPE, inv_id_in shipment_line.inv_id%TYPE, sl_quantity_in shipment_line.sl_quantity%TYPE);
  
END inv_ctl_pkg;
CREATE OR REPLACE PACKAGE BODY inv_ctl_pkg AS

create or replace PACKAGE BODY inv_ctl_pkg AS  

   FUNCTION CALC_ORDER_TOTAL (o_id_in IN orders.o_id%TYPE) RETURN NUMBER IS total_price NUMBER(10,2);    
      CURSOR order_price_cursor IS    
         SELECT inv.inv_price, ol.ol_quantity     
           FROM order_line ol    
              INNER JOIN inventory inv ON ol.inv_id = inv.inv_id   
                  WHERE ol.o_id = o_id_in;   
                    order_price_cursor_row order_price_cursor%ROWTYPE;   
                      BEGIN      
                       total_price := 0; 
                             OPEN order_price_cursor;  
                                FETCH order_price_cursor INTO order_price_cursor_row; 
                                    LOOP       
                                    EXIT WHEN order_price_cursor%NOTFOUND;  
                                             total_price := total_price + order_price_cursor_row.inv_price * order_price_cursor_row.ol_quantity;  
                                                   FETCH order_price_cursor INTO order_price_cursor_row; 
                                                       END LOOP;    
                                                        CLOSE order_price_cursor; 
                                                              RETURN (total_price); 
                                                                  END CALC_ORDER_TOTAL;  

PROCEDURE ORDER_PLACED (c_id IN customer.c_id%TYPE, method_pmt IN orders.o_methpmt%TYPE, os_id IN orders.os_id%TYPE) AS    
     o_id_new orders.o_id%TYPE;  
          BEGIN    
               SELECT o_id_seq.NEXTVAL INTO o_id_new FROM DUAL;   
                     INSERT INTO orders        VALUES (o_id_new, SYSDATE, method_pmt, c_id, os_id);   
   END ORDER_PLACED; 

     PROCEDURE ORDER_PLACED (c_last_in IN customer.c_last%TYPE, c_first_in IN customer.c_first%TYPE, method_pmt IN orders.o_methpmt%TYPE, os_id IN orders.os_id%TYPE) AS        
      o_id_new orders.o_id%TYPE;   
         c_id_in orders.c_id%TYPE;    
            BEGIN      
             SELECT o_id_seq.NEXTVAL INTO o_id_new FROM DUAL;     
                 SELECT c_id INTO c_id_in 
                       FROM customer  
                            WHERE c_first = c_first_in AND c_last = c_last_in; 
                                    INSERT INTO orders    
                                        VALUES (o_id_new, SYSDATE, method_pmt, c_id_in, os_id);  
                                            END ORDER_PLACED;  
      PROCEDURE INVENTORY_ORDERED (o_id_in IN order_line.o_id%TYPE, inv_id_in IN order_line.inv_id%TYPE, ol_quantity_in IN order_line.ol_quantity%TYPE) AS  
          BEGIN   
      INSERT INTO order_line 
            VALUES(o_id_in, inv_id_in, ol_quantity_in); 
                END INVENTORY_ORDERED;    
                 PROCEDURE CHANGED_MY_MIND (o_id_in IN order_line.o_id%TYPE, inv_id_in IN order_line.inv_id%TYPE, ol_quantity_in IN order_line.ol_quantity%TYPE)
        AS    
          BEGIN   
                UPDATE order_line    
                   SET ol_quantity = ol_quantity_in   
                       WHERE o_id = o_id_in AND inv_id = inv_id_in; 
                           END CHANGED_MY_MIND; 
           PROCEDURE SHIPMENT_RECEIVED (ship_id_in shipment_line.ship_id%TYPE, inv_id_in shipment_line.inv_id%TYPE, arrival DATE) AS 
            BEGIN 
                    UPDATE shipment_line     
                      SET sl_date_received = arrival 
                            WHERE ship_id = ship_id_in AND inv_id = inv_id_in;
                                 END SHIPMENT_RECEIVED;


      PROCEDURE SHIPMENT_RECEIVED (ship_id_in shipment_line.ship_id%TYPE, inv_id_in shipment_line.inv_id%TYPE, sl_quantity_in shipment_line.sl_quantity%TYPE, arrival DATE) AS  
          BEGIN 
                  UPDATE shipment_line 
                        SET sl_date_received = arrival,       
                            sl_quantity = sl_quantity_in 
                             WHERE ship_id = ship_id_in AND inv_id = inv_id_in; 
                                 END SHIPMENT_RECEIVED;

           PROCEDURE SHIPMENT_RECEIVED (ship_id_in shipment_line.ship_id%TYPE, inv_id_in shipment_line.inv_id%TYPE, sl_quantity_in shipment_line.sl_quantity%TYPE) AS
                 BEGIN   
      UPDATE shipment_line 
            SET sl_quantity = sl_quantity_in  
                 WHERE ship_id = ship_id_in AND inv_id = inv_id_in;
                      END SHIPMENT_RECEIVED;
                         END inv_ctl_pkg;