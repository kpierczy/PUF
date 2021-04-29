library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;

library work;
use     work.serial_lib.all;

entity SERIAL_CBUS_SUM is
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
    SYNCH_GOTOWA	:out std_logic;				-- sygnal potwierdzenia synchronizacji
    BLAD_ODBIORU	:out std_logic				-- sygnal bledu odbioru
  );
end SERIAL_CBUS_SUM;

architecture behavioural of SERIAL_CBUS_SUM is

  signal   adres	:std_logic_vector(L_ADRESOW*B_SLOWA-2 downto 0); -- magistrala adresowa
  signal   dana_wyj	:std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0); -- wyjsciowa magistrala danych
  signal   dana_wej	:std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0); -- wejsciowa magistrala danych
  signal   dostep	:std_logic;				-- flaga dostepu do magistrali
  signal   zapis	:std_logic;				-- flaga zapisu (gdy '1') lub odczytu (gdy '0')
  signal   strob	:std_logic;				-- flaga strobu zegara

  type     CBUStyp      is (RD, WR, RG);
  type     CBUSid       is (ARG1, ARG2, SUM);
  type     CBUSncfg     is record typ :CBUStyp; adr :integer; end record;
  type     CBUScfg      is array(CBUSid) of CBUSncfg;
  type     CBUSnody     is array(CBUSid) of std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0);
    
  impure function CBUSmat(cfg :CBUScfg) return CBUScfg is
    function matnode(id :CBUSid) return string is
      constant s :string := "{ '"&CBUSid'image(id)&"', '"&CBUStyp'image(cfg(id).typ)&"', "&integer'image(cfg(id).adr)&" }";
    begin
      for i in id to CBUSid'right loop
        next when i=id;
        return (s&", "&matnode(i));
      end loop;
      return(s);
    end function;
    constant s :string := LF&CR&"C = {{ "&integer'image(L_ADRESOW)&", "&integer'image(L_DANYCH)&", "&boolean'image(N_SERIAL)&" }, "&
      "{ "&matnode(CBUSid'left)& " }};"&LF&CR;
  begin
    assert false report s severity warning;  
    return (cfg);
  end function;

  constant CBUScsum    	:CBUScfg := CBUSmat((ARG1 => (RG, 5), ARG2 => (RG, 23), SUM => (RD, 124)));
  signal   CBUSnsum	:CBUSnody;

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

  lp: for i in CBUSid generate					-- petla generacyjna po identyfikatorach
    ip : if CBUScsum(i).typ=RG generate				-- warunek generacyjny dla typu rejestru
      process (R, C) is						-- proces obslugi zapisu rejestrow
      begin							-- poczatek ciala obslugi rejestrow
        if (R='1') then						-- asynchroniczna inicjalizacja rejestrow
          CBUSnsum(i) <= (others => '0');			-- wyzerowanie rejestr o identyfikatorze 'i'
        elsif (rising_edge(C)) then				-- synchroniczna obsluga rejestrow
          if (dostep='1' and zapis='1' and strob='1' and CBUScsum(i).adr=adres) then -- sprawdzanie warunkow zapisu
            CBUSnsum(i) <= dana_wyj;				-- zapisanie rejestru o identyfikatorze 'i'
          end if;						-- zakonczenie instukcji warunkowej
        end if;							-- zakonczenie instukcji warunkowej
      end process;						-- zakonczenie ciala obslugi zapisu rejestrow
    end generate;						-- zakonczenie warunku generacyjnego
  end generate;							-- zakonczenie petli generacyjnej

  CBUSnsum(SUM) <= CBUSnsum(ARG1) + CBUSnsum(ARG2);		-- przypisanie wartosci do rejestru 'SUM'
 
  process (CBUSnsum, adres) is					-- lista czulosci procesu
  begin								-- czesc wykonawcza procesu
    dana_wej <= (others => '0');				-- inicjalizacja danej wyjsciowej
    for i in CBUSid loop					-- petla po identyfikatora 'CBUSid'
      if ((CBUScsum(i).typ=RG or CBUScsum(i).typ=RD) and CBUScsum(i).adr=adres) then -- warunki wyboru odczytu danej
        dana_wej <= CBUSnsum(i);				-- wyslanie wartosci rejestru o identyfikatorze 'i'
	exit;							-- bezwarunkowe zakonczenie petli
      end if;							-- zakonczenie instrukcji wyboru
    end loop;							-- zakonczenie petli
  end process;							-- zakonczenie procesu

end behavioural;

