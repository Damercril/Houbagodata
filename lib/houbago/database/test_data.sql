-- Insérer un utilisateur de test
INSERT INTO public.users (id, firstname, lastname, phone, pin)
VALUES 
  ('test-user-id', 'John', 'Doe', '+225 0123456789', '1234');

-- Insérer un compte utilisateur de test
INSERT INTO public.user_accounts (user_id, balance, referral_code)
VALUES 
  ('test-user-id', 75000.0, 'TEST123');

-- Insérer quelques gains de test
INSERT INTO public.earnings (user_id, amount, date)
VALUES 
  ('test-user-id', 25000, CURRENT_DATE - INTERVAL '2 days'),
  ('test-user-id', 35000, CURRENT_DATE - INTERVAL '1 day'),
  ('test-user-id', 15000, CURRENT_DATE);

-- Insérer quelques notifications de test
INSERT INTO public.notifications (user_id, title, message, type, read)
VALUES 
  ('test-user-id', 'Nouveau gain', 'Vous avez reçu 25000 FCFA', 'earning', false),
  ('test-user-id', 'Nouvelle affiliation', 'Un nouveau chauffeur vous a rejoint', 'affiliation', false);
