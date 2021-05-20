entity SIGNAL_SEL is				-- deklaracja sprzegu 'SIGNAL_SEL'
  port (					-- deklaracja portow wejscia-wyjscia
    sel		:in  natural range 0 to 3;	-- deklaracja portu wejsciowego 'sel'
    argA	:in  bit_vector(3 downto 0);	-- deklaracja portu wejsciowego 'argA'
    argB	:in  bit_vector(3 downto 0);	-- deklaracja portu wejsciowego 'argB'
    rezultat	:out bit_vector(3 downto 0)	-- deklaracja portu wyjsciowego 'rezultat'
  );
end SIGNAL_SEL;	 				-- zakonczenie deklaracji sprzegu

architecture cialo of SIGNAL_SEL is		-- deklaracja ciala 'cialo' architektury

  signal przewod : bit_vector(3 downto 0);	-- deklaracja sygnalu

begin						-- poczatek czesci wykonawczej architektury

  with sel select				-- klauzula wyboru poprzez sygnal 'sel'
    przewod <= argA and argB when 0,		-- wybor 'argA and argB' gdy sel=0
               argA or  argB when 1,		-- wybor 'argA or argB' gdy sel=1
	       argA xor argB when 2,		-- wybor 'argA xor argB' gdy sel=2
               argA xor argA when others;	-- wybor 'argA and argA' w innych przypadkach

  rezultat <= przewod;				-- przypisanie sygnalu do portu wyjsciowego

end cialo;					-- zakonczenie ciala architektonicznego
