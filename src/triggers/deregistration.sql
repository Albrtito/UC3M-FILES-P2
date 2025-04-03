CREATE OR REPLACE TRIGGER trg_deregistration_on_deteriorated
BEFORE UPDATE OF condition ON copies
FOR EACH ROW
WHEN (NEW.condition = 'D')
BEGIN
  :NEW.deregistered := SYSDATE;
END;
/
