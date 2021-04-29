library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;

entity SERIAL_INTERF is
  generic (
    F_ZEGARA		:natural := 20000000;			-- czestotliwosc zegata w [Hz]
    L_MIN_BODOW		:natural := 110;			-- minimalna predkosc nadawania w [bodach]
    B_SLOWA		:natural := 8;				-- liczba bitow slowa danych (5-8)
    B_PARZYSTOSCI	:natural := 1;				-- liczba bitow parzystosci (0-1)
    B_STOPOW		:natural := 2;				-- liczba bitow stopu (1-2)
    N_SERIAL		:boolean := FALSE;			-- negacja logiczna sygnalu szeregowego
    N_SLOWO		:boolean := FALSE			-- negacja logiczna slowa danych
  );
  port (
    R			:in  std_logic;				-- sygnal resetowania
    C			:in  std_logic;				-- zegar taktujacy
    RX			:in  std_logic;				-- odbierany sygnal szeregowy
    TX			:out std_logic;				-- wysylany sygnal szeregowy
    RX_ODEBRANE		:out std_logic;				-- flaga potwierdzenia odbioru
    RX_SLOWO		:out std_logic_vector(B_SLOWA-1 downto 0); -- odebrane slowo danych
    TX_WOLNY		:out std_logic;				-- flaga gotowosci do nadawania
    TX_NADAJ		:in  std_logic;				-- flaga zadania nadania
    TX_SLOWO		:in  std_logic_vector(B_SLOWA-1 downto 0); -- wysylane slowo danych
    SYNCH_GOTOWA	:out std_logic;				-- wysylany sygnal gotowosci
    BLAD_ODBIORU	:out std_logic				-- wysylany sygnal bledu odbioru
  );
end SERIAL_INTERF;

architecture behavioural of SERIAL_INTERF is

  signal   wejscie	:std_logic_vector(0 to 1);		-- podwojny rejestr sygnalu RX
  
  constant SLOWO_ZERO	:std_logic_vector(B_SLOWA-1 downto 0) := (others => '0'); -- slowo z ustawiona wartoscia 0

  signal   srx_slowo	:std_logic_vector(B_SLOWA-1 downto 0);	-- odebrane slowo danych
  signal   srx_gotowe	:std_logic;				-- flaga potwierdzenia odbioru
  signal   srx_blad	:std_logic;				-- flaga wykrycia bledu w odbiorze

  signal   stx_slowo	:std_logic_vector(B_SLOWA-1 downto 0);	-- wysylane slowo danych
  signal   stx_nadaj	:std_logic;				-- flaga zadania nadawania
  signal   stx_zajety	:std_logic;				-- flaga potwierdzenia nadawania

  type     ETAP		is (START, SYNCH, TEST, AKCEPT, STOP);	-- lista instrukcji pracy synchronizatora
  signal   stan		:ETAP;					-- rejestr maszyny stanow synchronizatora

  constant T_MAX_BODU	:natural  := F_ZEGARA/L_MIN_BODOW; 	-- maksymalna wartosc zlicznia taktow dla bodu
  signal   T_BODU	:natural range 0 to T_MAX_BODU-1;	-- licznik taktow zegara jednego bodu

begin								-- cialo architekury sumowania

  srx: entity work.SERIAL_RX(behavioural)			-- instancja odbiornika szeregowego 'SERIAL_SYNCH_RX'
    generic map(						-- mapowanie parametrow biezacych
      F_ZEGARA             => F_ZEGARA,				-- czestotliwosc zegata w [Hz]
      L_MIN_BODOW          => L_MIN_BODOW,			-- predkosc minimlana nadawania w [bodach]
      B_SLOWA              => B_SLOWA,				-- liczba bitow slowa danych (5-8)
      B_PARZYSTOSCI        => B_PARZYSTOSCI,			-- liczba bitow parzystosci (0-1)
      B_STOPOW             => B_STOPOW,				-- liczba bitow stopu (1-2)
      N_RX                 => N_SERIAL,				-- negacja logiczna sygnalu szeregowego
      N_SLOWO              => N_SLOWO				-- negacja logiczna slowa danych
    )
    port map(							-- mapowanie sygnalow do portow
      R                    => R,				-- sygnal resetowania
      C                    => C,				-- zegar taktujacy
      T_BODU               => T_BODU,				-- liczba taktow zegara dla jednego bodu
      RX                   => RX,				-- odebrany sygnal szeregowy
      SLOWO                => srx_slowo,			-- odebrane slowo danych
      GOTOWE               => srx_gotowe,			-- flaga potwierdzenia odbioru
      BLAD                 => srx_blad				-- flaga wykrycia bledu w odbiorze
    );

  stx: entity work.SERIAL_TX(behavioural)			-- instancja nadajnika szeregowego 'SERIAL_TX'
    generic map(						-- mapowanie parametrow biezacych
      F_ZEGARA             => F_ZEGARA,				-- czestotliwosc zegata w [Hz]
      L_MIN_BODOW          => L_MIN_BODOW,			-- predkosc minimlana nadawania w [bodach]
      B_SLOWA              => B_SLOWA,				-- liczba bitow slowa danych (5-8)
      B_PARZYSTOSCI        => B_PARZYSTOSCI,			-- liczba bitow parzystosci (0-1)
      B_STOPOW             => B_STOPOW,				-- liczba bitow stopu (1-2)
      N_TX                 => N_SERIAL,				-- negacja logiczna sygnalu szeregowego
      N_SLOWO              => N_SLOWO				-- negacja logiczna slowa danych
    )
    port map(							-- mapowanie sygnalow do portow
      R                    => R,				-- sygnal resetowania
      C                    => C,				-- zegar taktujacy
      T_BODU               => T_BODU,				-- liczba taktow zegara dla jednego bodu
      TX                   => TX,				-- nadawany sygnal szeregowy
      SLOWO                => stx_slowo,			-- nadawane slowo danych
      NADAJ                => stx_nadaj,			-- flaga zadania nadawania
      WYSYLANIE            => stx_zajety			-- flaga potwierdzenia nadawania
    );

   process (R, C) is						-- proces kalkulatora

   begin							-- poczatek ciala procesu kalkulatora

     if (R='1') then						-- asynchroniczna inicjalizacja rejestrow
       wejscie	    <= (others => '0');				-- wyzerowanie rejestru sygnalu RX
       stx_slowo    <= (others => '0');				-- wyzerowanie nadawanego slowa danych
       stx_nadaj    <= '0';					-- wyzerowanie flagi zadania nadawania
       stan         <= START;					-- poczatkowy stan pracy synchronizatora
       T_BODU       <= 0;					-- wyzerowanie wartosci licznika czasu bodu
       RX_SLOWO     <= (others => '0');				-- wyzerowanie odebranego slowa danych
       RX_ODEBRANE  <= '0';					-- wyzerowanie flagi potwierdzenia odbioru
       TX_WOLNY	    <= '0';					-- wyzerowanie flagi gotowosci do nadawania
       SYNCH_GOTOWA <= '0';					-- wyzerowanie sygnalu uzyskania synchronizacji
       BLAD_ODBIORU <= '0';					-- wyzerowanie sygnalu bledu odbioru

     elsif (rising_edge(C)) then				-- synchroniczna praca kalkulatora
     
       wejscie(0) <= RX;					-- zarejestrowanie synchroniczne stanu sygnalu RX
       if (N_SERIAL = TRUE) then				-- badanie warunku zanegowania sygnalu szeregowego
         wejscie(0) <= not(RX);					-- zarejestrowanie synchroniczne zanegowanego sygnalu RX
       end if;							-- zakonczenie instukcji warunkowej  
       wejscie(1) <= wejscie(0);				-- zarejestrowanie dwoch kolejnych stanow sygnalu RX

       stx_nadaj    <= '0';					-- defaultowe wyzerowanie flaga zadania nadawania
       RX_ODEBRANE  <= '0';					-- defaultowe wyzerowanie flagi potwierdzenia odbioru
       RX_SLOWO     <= (others => '0');				-- defaultowe wyzerowanie odebranego slowa danych
       TX_WOLNY	    <= '0';					-- defaultowe wyzerowanie flagi gotowosci do nadawania
       SYNCH_GOTOWA <= '0';					-- defaultowe wyzerowanie sygnalu uzyskania synchronizacji
       BLAD_ODBIORU <= '0';					-- defaultowe wyzerowanie sygnalu bledu

       case stan is						-- badanie aktualnego stanu maszyny interpretera 

	 when START =>						-- obsluga stanu START
           T_BODU       <= 0;					-- wyzerowanie wartosci licznika czasu bodu
           SYNCH_GOTOWA <= '1';					-- ustawienie sygnalu gotowosci
           BLAD_ODBIORU <= '1';					-- ustawienie sygnalu bledu
	   if (wejscie(0)='1' and wejscie(1)='0') then		-- wykrycie poczatku bitu START
	     stan <= SYNCH;					-- przejscie do stanu SYNCH
	   end if;						-- zakonczenie instukcji warunkowej

	 when SYNCH =>						-- obsluga stanu SYNCHronizacji
	   T_BODU <= T_BODU +1;					-- zliczanie taktow dla jednego bodu
	   if (wejscie(0)='0' and wejscie(1)='1') then		-- wykrycie zakonczenia bitu START
             stx_nadaj <= '1';					-- ustawiona flaga zadania nadawania
             stx_slowo <= SLOWO_ZERO+X"9A";			-- wyslanie danej o wartosci bazowej HEX 9A
             stx_slowo(B_SLOWA-1) <= '1';			-- ustawienie najstarszego bitu na wartosc '1'
	     stan <= TEST;					-- przejscie do stanu SYNCH
	   elsif (T_BODU = T_MAX_BODU) then
	     stan <= START;					-- przejscie do stanu START
	   end if;						-- zakonczenie instukcji warunkowej

	 when TEST =>						-- obsluga stanu TESTowania
	   if (srx_blad='1') then				-- niepoprawne odebranie danej szeregowej 
	     stan <= STOP;					-- przejscie do stanu STOP
	   elsif (srx_gotowe='1') then				-- poprawne odebranie danej szeregowej
             stx_nadaj <= '1';					-- ustawiona flaga zadania nadawania
             if (srx_slowo /= 0) then				-- odebrano dana testowa
               stx_slowo <= not(srx_slowo);			-- wyslanie zanegowanej danej odebranej
	     else						-- odebranie danej akceptujacej
               stx_slowo <= srx_slowo;				-- wyslanie danej akceptujacej
	       stan <= AKCEPT;					-- przejscie do stanu AKCEPT
	     end if;						-- zakonczenie instukcji warunkowej
	   end if;						-- zakonczenie instukcji warunkowej

	 when AKCEPT =>						-- obsluga stanu AKCEPTacji
           SYNCH_GOTOWA <= '1';					-- ustawienie sygnalu poprawnej synchronizacji
	   if (srx_blad='1') then				-- niepoprawne odebranie danej szeregowej 
	     stan <= STOP;					-- przejscie do stanu START
	   else
             RX_ODEBRANE <= srx_gotowe;				-- poprawne odebranie danej szeregowej
             RX_SLOWO    <= srx_slowo;				-- odebrana dana szeregowa
	     if (TX_NADAJ='1') then				-- zadanie nadania danej
	       if (stx_zajety = '0' or stx_nadaj = '0') then	-- sprawdzanie czy nadajnik nie jest zajety
                 stx_nadaj <= '1';				-- ustawiona flaga zadania nadawania
		 stx_slowo <= TX_SLOWO;				-- podanie wartosci nadawanego slowa
               else						-- wariant, gdy nadajnik jest zajety
	         stan <= STOP;					-- przejscie do stanu STOP
	       end if;						-- zakonczenie instukcji warunkowej
	     else						-- wariant gdy brak zadania nadawania
	       TX_WOLNY <= not(stx_zajety) and not(stx_nadaj);	-- flaga gotowosci do nadawania
	     end if;						-- zakonczenie instukcji warunkowej
	   end if;						-- zakonczenie instukcji warunkowej

	 when STOP =>						-- obsluga stanu STOP (zatrzymania)
           BLAD_ODBIORU <= '1';					-- ustawienie sygnalu bledu odbioru

       end case;						-- zakonczenie instukcji warunkowego wyboru

     end if;							-- zakonczenie instukcji warunkowej porcesu

   end process;							-- zakonczenie ciala kalkulatora
   
end behavioural;

