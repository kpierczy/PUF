entity SIGNAL_COND_TB is			-- pusty sprzeg projektu symulacji
end SIGNAL_COND_TB;

architecture behavioural of SIGNAL_COND_TB is 	-- cialo architektoniczne projektu
  signal A	:natural range 0 to 15 := 0;	-- symulowane wejscie 'A' inicjowane na 0
  signal B	:natural range 0 to 15 := 0;	-- symulowane wejscie 'B' inicjowane na 0
  signal Y	:natural range 0 to 15;		-- obserwowane wyjscie 'Y'
  signal W	:natural range 0 to 3;		-- obserwowane wyjscie 'W'
  signal S	:natural range 0 to 3;		-- testowy sygnal wyboru 'S'
  signal T	:boolean;			-- testowy sygnal zgodnosci 'T'
begin						-- poczatek czesci wykonawczej architektury

  process is					-- proces bezwarunkowy
  begin						-- czesc wykonawcza procesu
    --wait for 10 ns; A <= A+1;
    wait for 10 ns; A <= (A+1) mod 16;		-- odczekanie 10 ns i zwiekszenie o 1 sygnalu A
  end process;					-- zakonczenie procesu
  
  process is begin
    wait for 16*10 ns; B <= (B+1) mod 16;	-- odczekanie 160 ns i zwiekszenie o 1 sygnalu B
  end process;
  
  signal_cond_inst: entity work.SIGNAL_COND(cialo) -- instancja projektu 'SIGNAL_COND'
    port map (				-- mapowanie portow
      argA     => A,			-- przypisanie sygnalu 'A' do portu 'argA'
      argB     => B,			-- przypisanie sygnalu 'B' do portu 'argB'
      rezultat => Y,			-- przypisanie sygnalu 'Y' do portu 'rezultat'
      wybor    => W			-- przypisanie sygnalu 'W' do portu 'wybor'
    );

  S <= 0 when A - 5 > B else		-- wybor gdy 'A - 5 > B'
       1 when A     > B else		-- wybor gdy 'A > B'
       2 when B - 7 > A else		-- wybor gdy 'B - 7 > A'
       3;				-- wybor w pozostalych przypadkach

  T <= (S = W);

end behavioural;			-- zakonczenie ciala architektonicznego
