-- Atomic shortlist: UPDATE applications + INSERT interviews in one transaction.
-- Run in Supabase SQL editor or via `supabase db push`.
--
-- Raises:
--   P0001 INVALID_APPLICATION_ID
--   P0001 APPLICATION_NOT_FOUND
--   P0001 APPLICATION_NOT_SHORTLISTABLE

CREATE OR REPLACE FUNCTION public.recruitment_shortlist_application(p_application_id text)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_row public.applications%ROWTYPE;
  v_norm text;
BEGIN
  IF p_application_id IS NULL OR btrim(p_application_id) = '' THEN
    RAISE EXCEPTION 'INVALID_APPLICATION_ID' USING ERRCODE = 'P0001';
  END IF;

  SELECT * INTO v_row FROM public.applications WHERE id = p_application_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'APPLICATION_NOT_FOUND' USING ERRCODE = 'P0001';
  END IF;

  v_norm := lower(btrim(coalesce(v_row.status, '')));

  -- Same gate as mobile ApplicationStatusActions.canUpdateStatus + pending normalization
  IF v_norm IN ('pending', 'applied', '') THEN
    UPDATE public.applications
    SET
      status = 'shortlisted',
      current_stage = 'telephone',
      updated_at = now()
    WHERE id = p_application_id;

    INSERT INTO public.interviews (application_id, stage, status)
    SELECT p_application_id, 'telephone', 'eligible'
    WHERE NOT EXISTS (
      SELECT 1
      FROM public.interviews i
      WHERE i.application_id = p_application_id
        AND i.stage = 'telephone'
    );
    RETURN;
  END IF;

  IF v_norm = 'shortlisted' THEN
    INSERT INTO public.interviews (application_id, stage, status)
    SELECT p_application_id, 'telephone', 'eligible'
    WHERE NOT EXISTS (
      SELECT 1
      FROM public.interviews i
      WHERE i.application_id = p_application_id
        AND i.stage = 'telephone'
    );
    RETURN;
  END IF;

  RAISE EXCEPTION 'APPLICATION_NOT_SHORTLISTABLE' USING ERRCODE = 'P0001';
END;
$$;

CREATE OR REPLACE FUNCTION public.recruitment_shortlist_applications(p_application_ids text[])
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_id text;
BEGIN
  IF p_application_ids IS NULL OR cardinality(p_application_ids) = 0 THEN
    RETURN;
  END IF;

  FOREACH v_id IN ARRAY p_application_ids
  LOOP
    PERFORM public.recruitment_shortlist_application(v_id);
  END LOOP;
END;
$$;

GRANT EXECUTE ON FUNCTION public.recruitment_shortlist_application(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.recruitment_shortlist_applications(text[]) TO authenticated;
