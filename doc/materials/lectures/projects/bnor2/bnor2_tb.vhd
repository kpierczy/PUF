entity BNOR2_TB is			-- pusty sprzeg projektu symulacji 'BNOR2_TB'
end BNOR2_TB;

architecture cialo_tb of BNOR2_TB is	-- cialo architektoniczne projektu 'cialo_tb'

  signal A	:bit;			-- symulowane wejscie A
  signal B	:bit;			-- symulowane wejscie B
  signal Y	:bit;			-- obserwowane wyjscie

begin

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    A <= '0';				-- przypisanie sygnalowi 'A' wartosci '0'
    wait for 10 ns;			-- odczekanie 10 ns
    A <= '1';				-- przypisanie sygnalowi 'A' wartosci '1'
    wait for 10 ns;			-- odczekanie 10 ns
  end process;				-- zakonczenie procesu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    B <= '0';				-- przypisanie sygnalowi 'B' wartosci '0'
    wait for 20 ns;			-- odczekanie 20 ns
    B <= '1';				-- przypisanie sygna³lowi 'B' wartosci '1'
    wait for 20 ns;			-- odczekanie 20 ns
  end process;				-- zakonczenie procesu

  bnor2_inst: entity work.BNOR2(cialo)	-- instancja projektu 'BNOR2'
    port map (				-- mapowanie portow
      A => A,				-- przypisanie sygnalu 'A' do portu 'A'
      B => B,				-- przypisanie sygnalu 'B' do portu 'B'
      Y => Y				-- przypisanie sygnalu 'Y' do portu 'Y'
    );
end cialo_tb;			        -- zakonczenie ciala architektonicznego 'cialo_tb'
