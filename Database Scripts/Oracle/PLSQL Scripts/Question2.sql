create or replace TRIGGER inv_update_from_sale
AFTER INSERT
   ON order_line
   FOR EACH ROW
   
DECLARE
  order_id order_line.o_id%TYPE;
  inventory_id order_line.inv_id%TYPE;
  quantity_ordered order_line.ol_quantity%TYPE;
  quantity_on_hand inventory.inv_qoh%TYPE;
  item_color inventory.color%TYPE;
  item_price inventory.inv_price%TYPE;
  item_desc item.item_desc%TYPE;
  total_price FLOAT := 0;
  
  CURSOR order_price_cursor IS
    SELECT inv.inv_price, ol.ol_quantity
    FROM order_line ol
    INNER JOIN inventory inv ON ol.inv_id = inv.inv_id
    WHERE ol.o_id = order_id;
  order_price_cursor_row order_price_cursor%ROWTYPE;
  
BEGIN

  order_id := :NEW.o_id;
  inventory_id := :NEW.inv_id;
  quantity_ordered := :NEW.ol_quantity;
  
  SELECT i.inv_qoh, i.color, i.inv_price, it.item_desc INTO quantity_on_hand, item_color, item_price, item_desc
  FROM inventory i
  JOIN item it ON i.item_id = it.item_id
  WHERE i.inv_id = inventory_id;
  
  quantity_on_hand := quantity_on_hand - quantity_ordered;
  
  total_price := total_price + (item_price * quantity_ordered);
  
  UPDATE inventory i
  SET i.inv_qoh = quantity_on_hand
  WHERE i.inv_id = inventory_id;
  
  OPEN order_price_cursor;
    FETCH order_price_cursor INTO order_price_cursor_row;
    LOOP
      EXIT WHEN order_price_cursor%NOTFOUND;
      
        total_price := total_price + (order_price_cursor_row.inv_price * order_price_cursor_row.ol_quantity);
                         
      FETCH order_price_cursor INTO order_price_cursor_row;
    END LOOP;
  CLOSE order_price_cursor;
    
  DBMS_OUTPUT.PUT_LINE('The total for order ' || order_id || ' is ' || TO_CHAR(total_price, '$999,999,999.99'));
  
  IF (quantity_on_hand < 0) THEN
    DBMS_OUTPUT.PUT_LINE('We need to get some more ' || item_color || ' ' || item_desc || 's.');
  END IF;
  
END;
