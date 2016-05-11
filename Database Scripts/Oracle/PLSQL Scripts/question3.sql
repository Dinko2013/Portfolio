create or replace TRIGGER inv_update_from_salechange
AFTER UPDATE
  OF ol_quantity
  ON order_line
  FOR EACH ROW
   
DECLARE
  inventory_id order_line.inv_id%TYPE;
  quantity_ordered order_line.ol_quantity%TYPE;
  quantity_on_hand inventory.inv_qoh%TYPE;
  
BEGIN

  --SELECT :OLD.inv_id INTO inventory_id
  --FROM order_line;
  
  inventory_id := :OLD.inv_id;
  
  SELECT i.inv_qoh INTO quantity_on_hand
  FROM inventory i
  WHERE i.inv_id = inventory_id;
  
  quantity_on_hand := quantity_on_hand + (:NEW.ol_quantity - :OLD.ol_quantity);
 
  UPDATE inventory
  SET inv_qoh = (quantity_on_hand)
  WHERE inv_id = inventory_id;
  
END;