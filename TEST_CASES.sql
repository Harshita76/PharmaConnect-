-- ███  SECTION C  –  NEGATIVE / EDGE‑CASE TESTS  ████████████████████████████
/* Each numbered block corresponds to a rule bullet in the PDF.
   We expect every attempt to violate a rule to raise SQLSTATE 45000 or 23000.
   ------------------------------------------------------------------------ */



-- -- (2)  Doctor must have at least one patient       →  delete should fail
-- CALL delete_doctor('D100');

-- -- (3)  Pharma‑company delete should cascade drugs
-- CALL delete_pharma_company('PharmB');
-- SELECT 'PharmB deleted; its drugs gone?' AS banner;
-- SELECT * FROM Drug WHERE ph_comp_name='PharmB';

-- -- (4)  Min‑10‑drugs rule on INSERT  (attempt to open PhZ with <10 rows)
-- CALL add_pharmacy('PhZ','999 Zero St','0000000000');
-- SELECT '--- expect error below (min‑10) ---' AS banner;
-- CALL update_stocks('D01','PharmA','PhZ',1.0,20);    -- 1st drug  → error

-- -- (5)  Min‑10‑drugs rule on DELETE
-- SELECT '--- expect error deleting last allowed item ---' AS banner;
-- DELETE FROM Sells
-- WHERE ph_name='PhX' AND trade_name='D10' AND ph_comp_name='PharmA'; -- leaves 9

-- -- (6)  Only NEWEST prescription kept  (back‑dated insert should be ignored)
-- CALL add_prescription('D100','P100','2025-03-01');  -- older than current
-- SELECT * FROM Prescription WHERE doc_id='D100' AND patient_id='P100';

-- -- (7)  One prescription per doctor‑patient per DATE
-- SELECT '--- expect error: duplicate date ---' AS banner;
-- CALL add_prescription('D100','P100','2025-04-01');  -- same date  → error

-- -- (8)  Contract supervisor update allowed
-- CALL update_contract('PhX','PharmA','2025-01-01','2026-01-01','Supervisor‑2');
-- SELECT * FROM Contract WHERE ph_name='PhX' AND ph_comp_name='PharmA';

-- -- (9)  Deleting a doctor when they cease to have patients  (should succeed)
-- CALL delete_patient('P100');  -- now D100 has zero patients
-- CALL delete_doctor('D100');   -- allowed because our logic auto‑deleted empty docs
-- SELECT 'D100 should be gone:' AS banner;  SELECT * FROM Doctor WHERE aadhar_id='D100';

-- -- End of test‑suite