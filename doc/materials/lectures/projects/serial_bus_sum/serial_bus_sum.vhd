library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;

library work;
use     work.serial_lib.all;

entity SERIAL_BUS_SUM is
  generic (
    L_ADRESOW		:natural := 2;				-- liczba slow przypadajacych na adres
    L_DANYCH		:natural := 4;				-- liczba slow przypadajacych na dana
    L_TAKTOW_ADRESU	:natural := 2;				-- liczba taktow stabilizacji adresu (i danej)
    L_TAKTOW_STROBU	:natural := 2;				-- liczba taktow trwania strobu
    L_TAKTOW_DANEJ	:natural := 2;				-- liczba taktow stabilizacji odbieranych danych
    F_ZEGARA		:natural := 20_000_000;			-- czestotliwosc zegata w [Hz]
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
    SYNCH_GOTOWA	:out std_logic;				-- sygnal potwierdzenia synchronizacji
    BLAD_ODBIORU	:out std_logic				-- sygnal bledu odbioru
  );
end SERIAL_BUS_SUM;

architecture behavioural of SERIAL_BUS_SUM is

  signal   adres	:std_logic_vector(L_ADRESOW*B_SLOWA-2 downto 0); -- magistrala adresowa
  signal   dana_wyj	:std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0); -- wyjsciowa magistrala danych
  signal   dana_wej	:std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0); -- wejsciowa magistrala danych
  signal   dostep	:std_logic;				-- flaga dostepu do magistrali
  signal   zapis	:std_logic;				-- flaga zapisu (gdy '1') lub odczytu (gdy '0')
  signal   strob	:std_logic;				-- flaga strobu zegara

  signal   rejestr5	:std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0); -- rejestr o adresie 5
  signal   rejestr23	:std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0); -- rejestr o adresie 23
  signal   rejestr124	:std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0); -- rejestr o adresie 124
  
begin								-- cialo architekury sumowania

  sint: entity work.SERIAL_BUS(behavioural)
    generic map (
      L_ADRESOW       => L_ADRESOW,
      L_DANYCH        => L_DANYCH,
      L_TAKTOW_ADRESU => L_TAKTOW_ADRESU,
      L_TAKTOW_STROBU => L_TAKTOW_STROBU,
      L_TAKTOW_DANEJ  => L_TAKTOW_DANEJ,
      F_ZEGARA        => F_ZEGARA,
      L_MIN_BODOW     => L_MIN_BODOW,
      B_SLOWA         => B_SLOWA,
      B_PARZYSTOSCI   => B_PARZYSTOSCI,
      B_STOPOW        => B_STOPOW,
      N_SERIAL        => N_SERIAL,
      N_SLOWO         => N_SLOWO
    )                     
    port map (            
      R               => R, 
      C               => C, 
      RX              => RX ,
      TX              => TX ,
      ADRES           => adres,
      DANA_WYJ        => dana_wyj,
      DANA_WEJ        => dana_wej,
      DOSTEP          => dostep,
      ZAPIS           => zapis,
      STROB           => strob,
      SYNCH_GOTOWA    => SYNCH_GOTOWA,
      BLAD_ODBIORU    => BLAD_ODBIORU
   );

   process (R, C) is						-- proces obslugi zapisu rejestrow
   begin							-- poczatek ciala obslugi rejestrow
     if (R='1') then						-- asynchroniczna inicjalizacja rejestrow
       rejestr5	 <= (others => '0');				-- wyzerowanie rejestru o adresie 5
       rejestr23 <= (others => '0');				-- wyzerowanie rejestru o adresie 23
     elsif (rising_edge(C)) then				-- synchroniczna obsluga rejestrow
       if (dostep='1' and zapis='1' and strob='1') then		-- sprawdzanie warunku zapisu z interfejsu
         if (adres = 5) then					-- sprawdzanie czy adres rowna sie 5
           rejestr5 <= dana_wyj;				-- zapisanie rejestru o adresie 5
	 elsif (adres = 23) then				-- sprawdzanie czy adres rowna sie 23
           rejestr23 <= dana_wyj;				-- zapisanie rejestru o adresie 23
         end if;						-- zakonczenie instukcji warunkowej
       end if;							-- zakonczenie instukcji warunkowej
     end if;							-- zakonczenie instukcji warunkowej
   end process;							-- zakonczenie ciala obslugi zapisu rejestrow

   rejestr124 <= rejestr5 + rejestr23;				-- przypisanie wartosci do rejestr124
 
   dana_wej <= rejestr5   when (adres = 5)   else		-- wyslanie wartosci rejestru dla adresu 5
               rejestr23  when (adres = 23)  else		-- wyslanie wartosci rejestru dla adresu 23
               rejestr124 when (adres = 124) else		-- wyslanie wartosci rejestru dla adresu 124
	       (others => '0');					-- wysylanie wartosci w pozostalych przypadkach
	       
end behavioural;

