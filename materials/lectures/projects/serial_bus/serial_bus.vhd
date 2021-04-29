library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;

library work;
use     work.serial_bus_lib.all;

entity SERIAL_BUS is
  generic (
    L_ADRESOW		:natural := 2;				-- liczba slow przypadajacych na adres
    L_DANYCH		:natural := 4;				-- liczba slow przypadajacych na dana
    L_TAKTOW_ADRESU	:natural := 2;				-- liczba taktow stabilizacji adresu (i danej)
    L_TAKTOW_STROBU	:natural := 2;				-- liczba taktow trwania strobu
    L_TAKTOW_DANEJ	:natural := 2;				-- liczba taktow stabilizacji odbieranych danych
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
    ADRES		:out std_logic_vector(L_ADRESOW*B_SLOWA-2 downto 0); -- magistrala adresowa
    DANA_WYJ		:out std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0); -- wyjsciowa magistrala danych
    DANA_WEJ		:in  std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0); -- wejsciowa magistrala danych
    DOSTEP		:out std_logic;				-- flaga dostepu do magistrali
    ZAPIS		:out std_logic;				-- flaga zapisu (gdy '1') lub odczytu (gdy '0')
    STROB		:out std_logic;				-- flaga strobu zegara
    SYNCH_GOTOWA	:out std_logic;				-- sygnal potwierdzenia synchronizacji
    BLAD_ODBIORU	:out std_logic				-- sygnal bledu odbioru
  );
end SERIAL_BUS;

architecture behavioural of SERIAL_BUS is

  signal rx_odebrane	:std_logic;				-- flaga potwierdzenia odbioru
  signal rx_slowo	:std_logic_vector(B_SLOWA-1 downto 0);	-- odebrane slowo danych
  signal tx_wolny	:std_logic;				-- flaga gotowosci do nadawania
  signal tx_nadaj	:std_logic;				-- flaga zadania nadania
  signal tx_slowo	:std_logic_vector(B_SLOWA-1 downto 0);	-- wysylane slowo danych
  signal sx_synch	:std_logic;				-- sygnal potwierdzenia synchronizacji 
  signal sx_blad	:std_logic;				-- sygnal bledu odbioru

  type     ETAP		is (S_ADRESU, Z_DANYCH, Z_WYKONAJ, Z_POTW, -->
                            O_WYKONAJ, O_DANYCH, O_POTW,	   -->
                            W_ADRESU, W_STROBU, W_DANEJ,	   -->
                            STOP);				-- lista instrukcji pracy intefejsu
  signal   stan		:ETAP;					-- rejestr maszyny stanow intefejsu
  signal   powrot	:ETAP;					-- stan powrotu maszyny stanow intefejsu
  signal   licznik	:natural;				-- rejestr maszyny stanow intefejsu
  signal   s_testowe	:std_logic_vector(B_SLOWA-1 downto 0);	-- slowo testowe
  signal   buf_danej	:std_logic_vector(DANA_WEJ'range);	-- bufor danej wejsciowej
  
begin								-- cialo architekury sumowania

  sdx: entity work.SERIAL_INTERF(behavioural)
    generic map (
      F_ZEGARA        => F_ZEGARA,
      L_MIN_BODOW     => L_MIN_BODOW,
      B_SLOWA         => B_SLOWA,
      B_PARZYSTOSCI   => B_PARZYSTOSCI,
      B_STOPOW        => B_STOPOW,
      N_SERIAL	      => N_SERIAL,
      N_SLOWO         => N_SLOWO
    )
    port map (
      R               => R,
      C               => C,
      RX              => RX,
      TX              => TX,
      RX_ODEBRANE     => rx_odebrane,
      RX_SLOWO        => rx_slowo,
      TX_WOLNY        => tx_wolny,
      TX_NADAJ        => tx_nadaj,
      TX_SLOWO        => tx_slowo,
      SYNCH_GOTOWA    => sx_synch,
      BLAD_ODBIORU    => sx_blad
    );

  process (R, C) is						-- proces interfejsu

    variable slowo :std_logic_vector(B_SLOWA-1 downto 0);	-- wysylane slowo danych

  begin								-- poczatek ciala procesu interfejsu

    if (R='1') then						-- asynchroniczna inicjalizacja rejestrow
      tx_nadaj     <= '0';					-- wyzerowanie flagi zadania nadawania
      tx_slowo	   <= (others => '0');				-- wyzerowanie nadawanego slowa danych
      stan         <= S_ADRESU;					-- poczatkowy stan pracy interfejsu
      powrot       <= S_ADRESU;					-- poczatkowy stan pracy interfejsu
      licznik      <= 0;					-- wyzerowanie licznika slow
      s_testowe    <= (others => '0');				-- wyzerowanie slowa testowego
      ADRES        <= (others => '0');				-- wyzerowanie adresu interfejsu
      DANA_WYJ     <= (others => '0');				-- wyzerowanie danej wyjsciowej interfejsu
      DOSTEP	   <= '0';					-- wyzerowanie flagi dostepu do magistrali
      ZAPIS	   <= '0';					-- wyzerowanie flagi zapisu
      STROB	   <= '0';					-- wyzerowanie flagi strobu zegara
      SYNCH_GOTOWA <= '0';					-- wyzerowanie potwierdzenia synchronizacji
      BLAD_ODBIORU <= '0';					-- wyzerowanie sygnalu bledu
      buf_danej    <= (others => '0');				-- wyzerowanie bufora danej wejsciowej

    elsif (rising_edge(C)) then					-- synchroniczna praca interfejsu

      tx_nadaj     <= '0';					-- defaultowe ustawienie flagi zadania nadawania
      DOSTEP       <= '0';					-- wyzerowanie flagi dostepu do magistrali
      STROB        <= '0';					-- wyzerowanie flagi strobu zegara
      BLAD_ODBIORU <= '0';					-- wyzerowanie sygnalu bledu

      if (sx_blad = '1') then					-- sprawdzenie, czy 'SERIAL_DUPLEX' zglosil blad
        stan <= STOP;						-- ustwienie stanu 'STOP' maszyny interfejsu
      elsif (sx_synch = '0') then				-- sprawdzenie, czy 'SERIAL_DUPLEX' nie ma synchronizacji
        stan      <= S_ADRESU;					-- ustwienie stanu 'S_ADRESU' maszyny interfejsu
        licznik   <= 0;						-- wyzerowanie licznika slow
        s_testowe <= (others => '0');				-- wyzerowanie slowa testowego
      else							-- wariant, gdy 'SERIAL_DUPLEX' jest zsynchronizowany
        SYNCH_GOTOWA <= '1';					-- ustawiennie potwierdzenia synchronizacji
        case stan is						-- badanie aktualnego stanu maszyny interfejsu 

	  when S_ADRESU =>					-- obsluga stanu Slowo_ADRESU
	    if (rx_odebrane = '1') then				-- sprawdzanie czy odebrano slowo
	      if (licznik = 0) then				-- sprawdzanie, czy nadawany jest pierwsze slowo adresu
	        slowo := (others => '0');			-- wyznaczenie i ustawienie poczatkowej wartosci slowa
              else						-- wariant, gdy nadawane sa nastepne slowaadresu
	        slowo := tx_slowo;				-- wyznaczenie i ustawienie wysylanego slowa zwrotnego
              end if;						-- zakonczenie instukcji warunkowej
	      tx_slowo <= test_slow(slowo, rx_slowo);		-- wyznaczenie i ustawienie wysylanego slowa zwrotnego
	      tx_nadaj <= '1';					-- ustawienie flagi zadania nadawania
	      for i in 0 to L_ADRESOW-1 loop			-- petla po wszystkich indeksach bufora adresowego
	        if (i = licznik) then				-- sprawdzenie, czy indek jest rowny wartosci licznika
		  if (i /= L_ADRESOW-1) then			-- sprawdzenie, czy nie jest to ostatnie slowo adresu
		    ADRES((i+1)*B_SLOWA-1 downto i*B_SLOWA) <= rx_slowo; -- przepisanie slowa do czesci adresu interfejsu
		    licznik <= licznik + 1;			-- zwiekszenie licznika o jeden
		  else						-- wariant, gdy jest to ostatnie slowo adresu
		    ADRES(ADRES'left downto i*B_SLOWA) <= rx_slowo(B_SLOWA-2 downto 0); -- przepisanie ostatniego slowa do adresu
		    licznik <= 0;				-- wyzerowanie licznika
		    if (rx_slowo(B_SLOWA-1) = '1') then		-- sprawdzenie czy jest to operacja zapisu
                      ZAPIS <= '1';				-- ustawienie flagi operacji zapisu
                      stan  <= Z_DANYCH;			-- ustwienie stanu 'Z_DANYCH' maszyny interfejsu
		    else					-- wariant, gdy jest to operacja odczytu
                      ZAPIS  <= '0';				-- ustawienie flagi operacji zapisu
                      stan   <= O_WYKONAJ;			-- ustwienie stanu 'W_ADRESU' maszyny interfejsu
                    end if;					-- zakonczenie instukcji warunkowej
                  end if;					-- zakonczenie instukcji warunkowej
                end if;						-- zakonczenie instukcji warunkowej
	      end loop;						-- zakonczenie instukcji petli
            end if;						-- zakonczenie instukcji warunkowej

	  when Z_DANYCH =>					-- obsluga stanu Zapis_DANYCH
	    if (rx_odebrane = '1') then				-- sprawdzanie czy odebrano slowo
	      tx_nadaj <= '1';					-- ustawienie flagi zadania nadawania
	      tx_slowo <= test_slow(tx_slowo, rx_slowo);	-- wyznaczenie i ustawienie wysylanego slowa zwrotnego
	      for i in 0 to L_DANYCH-1 loop			-- petla po wszystkich indeksach bufora adresowego
	        if (i = licznik) then				-- sprawdzenie, czy indek jest rowny wartosci licznika
		  DANA_WYJ((i+1)*B_SLOWA-1 downto i*B_SLOWA) <= rx_slowo; -- przepisanie slowa do czesci danej wyjsciowej interfejsu
		  if (i /= L_DANYCH-1) then			-- sprawdzenie, czy nie jest to ostatnie slowo adresu
		    licznik <= licznik + 1;			-- zwiekszenie licznika o jeden
		  else						-- wariant, gdy jest to ostatnie slowo adresu
		    licznik <= 0;				-- wyzerowanie licznika
                   stan    <= Z_WYKONAJ;			-- ustwienie stanu 'Z_WYKONAJ' maszyny interfejsu
                  end if;					-- zakonczenie instukcji warunkowej
                end if;						-- zakonczenie instukcji warunkowej
	      end loop;						-- zakonczenie instukcji petli
            end if;						-- zakonczenie instukcji warunkowej

	  when Z_WYKONAJ =>					-- obsluga stanu Zapis_WYKONAJ
	    if (rx_odebrane = '1') then				-- sprawdzanie czy odebrano slowo
	      if (rx_slowo = tx_slowo)	then			-- sprawdzenie czy jest zgodnosc slow testowych
                stan   <= W_ADRESU;				-- ustwienie stanu 'W_ADRESU' maszyny interfejsu
                powrot <= Z_POTW;				-- ustwienie stanu powrotu 'Z_POTW' maszyny interfejsu
              else						-- wariant, gdy jslowa testowe ne sa zgodne
                stan <= STOP;					-- ustwienie stanu 'STOP' maszyny interfejsu
              end if;						-- zakonczenie instukcji warunkowej
            end if;						-- zakonczenie instukcji warunkowej

	  when Z_POTW =>					-- obsluga stanu Zapis_POTWierdzenie
	    tx_nadaj  <= '1';					-- ustawienie flagi zadania nadawania
	    tx_slowo  <= test_slow(tx_slowo, rx_slowo);		-- wyznaczenie i ustawienie wysylanego slowa zwrotnego
            stan   <= S_ADRESU;					-- ustwienie stanu 'S_ADRESU' maszyny interfejsu

	  when O_WYKONAJ =>					-- obsluga stanu Odczyt_WYKONAJ
	    if (rx_odebrane = '1') then				-- sprawdzanie czy odebrano slowo
	      if (rx_slowo = tx_slowo)	then			-- sprawdzenie czy jest zgodnosc slow testowych
                stan   <= W_ADRESU;				-- ustwienie stanu 'W_ADRESU' maszyny interfejsu
                powrot <= O_DANYCH;				-- ustwienie stanu powrotu 'Z_POTW' maszyny interfejsu
              else						-- wariant, gdy jslowa testowe ne sa zgodne
                stan <= STOP;					-- ustwienie stanu 'STOP' maszyny interfejsu
              end if;						-- zakonczenie instukcji warunkowej
            end if;						-- zakonczenie instukcji warunkowej

	  when O_DANYCH =>					-- obsluga stanu Odczyt_DANYCH
	    if (licznik = 0) then				-- sprawdzanie, czy nadawany jest pierwsze slowo danych
              slowo     := buf_danej(B_SLOWA-1 downto 0);	-- przepisanie slowa z najmlodszej czesci danej z interfejsu
	      tx_slowo  <= slowo;				-- ustawienie wysylanego slowa zwrotnego
	      tx_nadaj  <= '1';					-- ustawienie flagi zadania nadawania
	      s_testowe <= test_slow(tx_slowo, slowo);		-- wyznaczenie i ustawienie slowa testowego
	      if (L_DANYCH = 1) then				-- zbadanie, czy jest wysylane jedno slowo danych
                stan    <= O_POTW;				-- ustwienie stanu 'O_POTW' maszyny interfejsu
              else						-- wariant, gdy jest wysylane ponad jedno slowo danych
                licznik <= licznik + 1;				-- zwiekszenie licznika o jeden
              end if;						-- zakonczenie instukcji warunkowej
            else						-- wariant, gdy jslowa testowe ne sa zgodne
	      if (rx_odebrane = '1') then			-- sprawdzanie czy odebrano slowo
	        if (rx_slowo = s_testowe) then			-- sprawdzenie czy jest zgodnosc slow testowych
	          for i in 1 to L_DANYCH-1 loop			-- petla po wszystkich indeksach bufora adresowego
	            if (i = licznik) then			-- sprawdzenie, czy indek jest rowny wartosci licznika
                      slowo     := buf_danej((i+1)*B_SLOWA-1 downto i*B_SLOWA); -- wydzielenie slowa z czesci danej z interfejsu
	              tx_slowo  <= slowo;			-- ustawienie wysylanego slowa zwrotnego
	              tx_nadaj  <= '1';				-- ustawienie flagi zadania nadawania
	              s_testowe <= test_slow(s_testowe, slowo);	-- wyznaczenie i ustawienie  slowa testowego
	              if (licznik = L_DANYCH-1) then		-- zbadanie, czy wysylane jest ostatnie slowo danej z interfejsu
                        licznik <= 0;				-- wyzerowanie licznika
                        stan <= O_POTW;				-- ustwienie stanu 'O_POTW' maszyny interfejsu
                      else					-- wariant, gdy sa slowa danej z interfejsu do wyslania
                        licznik <= licznik + 1;			-- zwiekszenie licznika o jeden
                      end if;					-- zakonczenie instukcji warunkowej
                    end if;					-- zakonczenie instukcji warunkowej
	          end loop;					-- zakonczenie instukcji petli
                else						-- wariant, gdy slowa testowe ne sa zgodne
                  stan <= STOP;					-- ustwienie stanu 'STOP' maszyny interfejsu
                end if;						-- zakonczenie instukcji warunkowej
              end if;						-- zakonczenie instukcji warunkowej
            end if;						-- zakonczenie instukcji warunkowej

	  when O_POTW =>					-- obsluga stanu Odczyt_POTWierdzenie
	    if (rx_odebrane = '1') then				-- sprawdzanie czy odebrano slowo
	      if (rx_slowo = s_testowe) then			-- sprawdzenie czy jest zgodnosc slow testowych
	        tx_nadaj  <= '1';				-- ustawienie flagi zadania nadawania
	        tx_slowo  <= test_slow(s_testowe, rx_slowo);	-- wyznaczenie i ustawienie wysylanego slowa zwrotnego
                stan   <= S_ADRESU;				-- ustwienie stanu 'S_ADRESU' maszyny interfejsu
              else						-- wariant, gdy slowa testowe ne sa zgodne
                stan <= STOP;					-- ustwienie stanu 'STOP' maszyny interfejsu
              end if;						-- zakonczenie instukcji warunkowej
            end if;						-- zakonczenie instukcji warunkowej

	  when W_ADRESU =>					-- obsluga stanu Wyslanie_ADRESU
            DOSTEP <= '1';					-- ustawienie flagi dostepu do magistrali
	    if (licznik = L_TAKTOW_ADRESU) then			-- sprawdzenie, czy osiagnieto opoznienie
              licznik <= 0;					-- wyzerowanie licznika
              STROB   <= '1';					-- ustawienie flagi strobu zegara
              stan    <= W_STROBU;				-- ustwienie stanu 'W_ADRESU' maszyny interfejsu
            else						-- wariant, gdy trwa odliczanie opoznienia
              licznik <= licznik + 1;				-- zwiekszenie licznika o jeden
            end if;						-- zakonczenie instukcji warunkowej

	  when W_STROBU =>					-- obsluga stanu Wyslanie_STROBU
            buf_danej <= DANA_WEJ;				-- zapamietanie sanej wejsciowej do interfejsu
	    if (licznik = L_TAKTOW_STROBU-1) then		-- sprawdzenie, czy osiagnieto opoznienie
              licznik <= 0;					-- wyzerowanie licznika
	      if (L_TAKTOW_DANEJ /= 0) then			-- sprawdzenie, czy wystepuje opoznienie danej
                DOSTEP <= '1';					-- ustawienie flagi dostepu do magistrali
                stan   <= W_DANEJ;				-- ustwienie stanu 'W_ADRESU' maszyny interfejsu
              else						-- wariant, gdy opoznienie danej nie wystepuje
                stan <= powrot;					-- ustwienie stanu 'Z_POTW' maszyny interfejsu
              end if;						-- zakonczenie instukcji warunkowej
            else						-- wariant, gdy trwa odliczanie opoznienia
              DOSTEP  <= '1';					-- ustawienie flagi dostepu do magistrali
              STROB   <= '1';					-- ustawienie flagi strobu zegara
              licznik <= licznik + 1;				-- zwiekszenie licznika o jeden
            end if;						-- zakonczenie instukcji warunkowej

	  when W_DANEJ =>					-- obsluga stanu Wystawienie_DANEJ
	    if (licznik = L_TAKTOW_DANEJ-1) then		-- sprawdzenie, czy osiagnieto opoznienie
              licznik <= 0;					-- wyzerowanie licznika
              stan <= powrot;					-- ustwienie stanu 'Z_POTW' maszyny interfejsu
            else						-- wariant, gdy trwa odliczanie opoznienia
              DOSTEP <= '1';					-- ustawienie flagi dostepu do magistrali
              buf_danej <= DANA_WEJ;				-- zapamietanie sanej wejsciowej do interfejsu
              licznik <= licznik + 1;				-- zwiekszenie licznika o jeden
            end if;						-- zakonczenie instukcji warunkowej

	  when STOP =>						-- obsluga stanu STOP (zatrzymania)
            SYNCH_GOTOWA <= '0';				-- wyzerowanie potwierdzenia synchronizacji
            BLAD_ODBIORU <= '1';				-- ustawienie sygnalu bledu odbioru

        end case;						-- zakonczenie instukcji warunkowego wyboru

      end if;							-- zakonczenie instukcji warunkowej

    end if;							-- zakonczenie instukcji warunkowej
   
  end process;							-- zakonczenie ciala interfejsu
   
end behavioural;

