entity FUNCTION_OVERSUM is					-- deklaracja sprzegu FUNCTION_OVERSUM'
  port (  A1 : in  bit_vector(4 downto 0);			-- deklaracja portu wejsciowego 'A1'
          A2 : in  bit_vector(3 downto 0);			-- deklaracja portu wejsciowego 'A2'
          A3 : in  bit_vector(2 downto 0);			-- deklaracja portu wejsciowego 'A3'
	  Y2 : out bit_vector(4 downto 0);	 		-- deklaracja portu wyjsciowego 'Y2'
	  Y3 : out bit_vector(5 downto 0));	 		-- deklaracja portu wyjsciowego 'Y3'
end FUNCTION_OVERSUM;	 					-- zakonczenie deklaracji naglowka

architecture cialo of FUNCTION_OVERSUM is			-- deklaracja ciala 'cialo' architektury

  function sumator(A, B :bit_vector) return bit_vector is 	-- utworzenie przeciazonej funkcji 'sumator'
  
    function max(A,B :positive) return positive is		-- utworzenie wewnetrznej funkcji 'max'
    begin							-- czesc wykonawcza procedury
      if (A>=B) then return A; end if;				-- zbadanie i zwrocenie wartosci 'A' gdy nie mniejsze niz 'B'
      return B;							-- zwrocenie wartosci 'B'
    end function max;						-- zakonczenie funkcji
    
    constant N : positive := max(A'length,B'length);		-- utworzenie stalej 'N' o watosci maksymalnej dlugosci wektora
    variable AN, BN, Y : bit_vector(N downto 0) := (others => '0'); -- utworzenie zmiennych 'AN', 'BN', 'Y'
    
    function sum(A, B :bit_vector) return bit_vector is 	-- utworzenie funkcji  'sum'
      variable P, S : bit;					-- utworzenie zmiennych 'P' i 'S' w procedurze
      variable Y : bit_vector(A'range);				-- utworzenie zmiennej 'Y' w procedurze
      procedure sum(A, B :bit; S :out bit ; P :inout bit) is	-- utworzenie wewnetrznej procedury 'sum'
      begin							-- czesc wykonawcza procedury
        if (P='0') then						-- badanie czy bit przeniesienia jest rowny '0'
          S := A xor B;						-- sumowanie bitowe funkcja 'xor'
          P := A and B;						-- wyznaczenie bitu przeniesienia funkcja 'and'
        else							-- wariant dla 'P' rownego '1'
          S := A xnor B;					-- sumowanie bitowe funkcja 'xnor'
          P := A or   B;					-- wyznaczenie bitu przeniesienia funkcja 'or'
        end if;							-- zakonczenie instukcji warunkowej
      end procedure sum;					-- zakonczenie procedury
    begin							-- czesc wykonawcza procedury
      P := '0';							-- ustawienie wartosci poczatkowej 'P' na '0'
      for i in 0 to Y'length-1 loop				-- petla po kolejnych bitach dla identyfikatora 'i'
        sum(A(i),B(i),S,P);					-- wywolanie procedury wewnetrznej 'sum'
        Y(i) := S;						-- przypisanie zmiennej 'S' do portu 'Y(i)'
      end loop;							-- zakonczenie petli
      return Y;							-- przypisanie zmiennej'P' do portu 'C'
    end function sum;						-- zakonczenie funcji
 
  begin								-- czesc wykonawcza procedury
    AN(A'range) := A;						-- czesciowe przypisanie zmiennej'AN'
    BN(B'range) := B;						-- czesciowe przypisanie zmiennej'BN'
    return sum(AN, BN);						-- wywolanie przeciazonej procedury 'sum'
  end function sumator;						-- zakonczenie procedury


  function sumator(A, B :bit_vector; L: positive) return bit_vector is -- utworzenie przeciazonej funkcji 'sumator'
    constant S :bit_vector := sumator(A, B);			-- utworzenie stalej 'S' o wartosci zwroconej przez 'sumator'
    variable Y :bit_vector(L-1 downto 0) := (others =>'1');	-- utworzenie zmiennej 'Y' o wartosci maksymalnej
  begin								-- czesc wykonawcza procedury
    if (L<S'length) then					-- badanie czy rozmiar 'L' jest mniejszy niz wektora 'S'
      for i in L to S'length-1 loop				-- petla po nadmiarowych bitach wektora 'S'
        if (S(i)='1') then					-- badanie czy bit 'S(i)'='1'
          return Y;						-- zwrocenie zmiennej 'Y' z wartoscia maksymalna
        end if;							-- zakonczenie instukcji warunkowej
      end loop;							-- zakonczenie petli
      return S(L-1 downto 0);					-- zwrocenie czesci zmiennej 'S' o rozmiarze 'L'
    end if;							-- zakonczenie instukcji warunkowej
    Y := (others => '0');					-- przypisanie wartosci '0' do zmiennej 'Y'
    Y(S'range) := S;						-- czesciowe przypisanie zmiennej'Y'
    return Y;							-- zwrocenie zmiennej 'Y'
  end function sumator;						-- zakonczenie procedury


  function sumator(A, B, C :bit_vector; L: positive) return bit_vector is -- utworzenie przeciazonej funkcji 'sumator'
  begin								-- czesc wykonawcza procedury
    return sumator(A,sumator(B,C),L);				-- zagniezdzone wywolanie przeciazonych funcji 'sumator'
  end function sumator;						-- zakonczenie procedury


begin								-- poczatek czesci wykonawczej

  Y2 <= sumator(A1, A2, Y2'length);				-- wywolanie przeciazonej procedury 'sumator'
  Y3 <= sumator(A1, A2, A3, Y3'length);				-- wywolanie przeciazonej procedury 'sumator'

end architecture cialo;						-- zakonczenie deklaracji ciala 'cialo'
