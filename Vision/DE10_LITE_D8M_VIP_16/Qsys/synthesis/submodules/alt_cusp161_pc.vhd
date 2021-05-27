-- Legal Notice: (C)2006 Altera Corporation. All rights reserved.  Your
-- use of Altera Corporation's design tools, logic functions and other
-- software and tools, and its AMPP partner logic functions, and any
-- output files any of the foregoing (including device programming or
-- simulation files), and any associated documentation or information are
-- expressly subject to the terms and conditions of the Altera Program
-- License Subscription Agreement or other applicable license agreement,
-- including, without limitation, that your use is for the sole purpose
-- of programming logic devices manufactured by Altera and sold by Altera
-- or its authorized distributors.  Please refer to the applicable
-- agreement for further details.

LIBRARY IEEE, ALTERA;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.textio.ALL;

USE altera.ALT_CUSP161_PACKAGE.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

ENTITY alt_cusp161_pc IS
  GENERIC (
        NAME         : STRING := "";
        OPTIMIZED    : INTEGER := OPTIMIZED_ON;
        FAMILY       : INTEGER := FAMILY_STRATIX;
        PROGRAM_FILE : STRING := "";
        PROGRAM_TRACE: STRING := "program.trace";
        LATENCY      : INTEGER := 3;
        DECODE_LATENCY : INTEGER := 2;
        INFER_MEMORY : INTEGER := 0;
        PC_WIDTH     : INTEGER := 16;
        PC_NUM_WORDS : INTEGER := 256; 
        PCW_WIDTH    : INTEGER := 32
  );
  PORT (
        clock        : IN STD_LOGIC;
        reset        : IN STD_LOGIC;
        ena          : IN STD_LOGIC := '1';
    
        pcw          : OUT STD_LOGIC_VECTOR( PCW_WIDTH-1 DOWNTO 0);
        pc           : OUT STD_LOGIC_VECTOR( PC_WIDTH-1  DOWNTO 0);
        pcf          : OUT STD_LOGIC_VECTOR( PC_WIDTH-1  DOWNTO 0); -- Value of PC for the fetch stage
        step         : OUT STD_LOGIC;
        stallnext    : OUT STD_LOGIC;
        nextpc       : IN  STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
        usenextpc    : IN  STD_LOGIC := '0';
        usenextpc_en : IN  STD_LOGIC := '0';
        hold         : IN  STD_LOGIC := '0';
        hold_en      : IN  STD_LOGIC := '0'
  );
END;


ARCHITECTURE syn OF alt_cusp161_pc IS

    COMPONENT altsyncram 
        GENERIC 
        (
            operation_mode                 :  string := "SINGLE_PORT";    -- "BIDIR_DUAL_PORT";
            -- port a parameters
            width_a                        :  integer := 8;    -- 1;
            widthad_a                      :  integer := 2;    -- 1;
            numwords_a                     :  integer := 4;    -- 1;
            -- registering parameters
            -- port a read parameters
            outdata_reg_a                  :  string := "UNREGISTERED";    
            -- clearing parameters
            address_aclr_a                 :  string := "NONE";    
            outdata_aclr_a                 :  string := "NONE";    
            -- clearing parameters
            -- port a write parameters
            indata_aclr_a                  :  string := "CLEAR0";    
            wrcontrol_aclr_a               :  string := "CLEAR0";    
            -- clear for the byte enable port reigsters which are clocked by clk0
            byteena_aclr_a                 :  string := "NONE";    
            -- width of the byte enable ports. if it is used, must be WIDTH_WRITE_A/8 or /9
            width_byteena_a                :  integer := 1;    
            -- port b parameters
            width_b                        :  integer := 8;    -- 1;
            widthad_b                      :  integer := 4;    -- 1;
            numwords_b                     :  integer := 4;    -- 1;
            -- registering parameters
            -- port b read parameters
            rdcontrol_reg_b                :  string := "CLOCK1";    
            address_reg_b                  :  string := "CLOCK1";    
            outdata_reg_b                  :  string := "UNREGISTERED";    
            -- clearing parameters
            outdata_aclr_b                 :  string := "NONE";    
            rdcontrol_aclr_b               :  string := "NONE";    
            -- registering parameters
            -- port b write parameters
            indata_reg_b                   :  string := "CLOCK1";    
            wrcontrol_wraddress_reg_b      :  string := "CLOCK1";    
            -- registering parameter for the byte enable reister for port b
            byteena_reg_b                  :  string := "CLOCK1";    
            -- clearing parameters
            indata_aclr_b                  :  string := "NONE";    
            wrcontrol_aclr_b               :  string := "NONE";    
            address_aclr_b                 :  string := "NONE";    
            -- clear parameter for byte enable port register
            byteena_aclr_b                 :  string := "NONE";    
            -- width of the byte enable ports. if it is used, must be WIDTH_WRITE_A/8 or /9
            width_byteena_b                :  integer := 1;    
            -- width of a byte for byte enables
            -- global parameters
            byte_size                      :  integer := 8; 
            -- SPR 106776 : remove redundant parameters   
            --      read_during_write_mode_port_a  :  string := "NEW_DATA_ON_FALLING_EDGE";    
            --      read_during_write_mode_port_b  :  string := "NEW_DATA_ON_FALLING_EDGE";    
            -- mixed-port feed-through mode choices are "OLD_DATA" or "DONT_CARE"
            read_during_write_mode_mixed_ports: string := "DONT_CARE";    
            -- ram block type choices are "AUTO", "M512", "M4K" and "MEGARAM"
            ram_block_type                 :  string := "AUTO";    
            -- general operation parameters
            init_file                      :  string := "UNUSED";    
            init_file_layout               :  string := "UNUSED";    
            maximum_depth                  :  integer := 0;    
            intended_device_family         : string  := "Stratix";
            -- bogus lpm_hint parameter?
            lpm_hint                       :  string := "UNUSED";
            lpm_type                        : string := "altsyncram" 
        );
        PORT 
        (
            wren_a                  : IN STD_LOGIC := '0';   
            wren_b                  : IN STD_LOGIC := '0';   
            rden_b                  : IN STD_LOGIC := '1';   
            data_a                  : IN STD_LOGIC_VECTOR(width_a - 1 DOWNTO 0):= (OTHERS => '0');   
            data_b                  : IN STD_LOGIC_VECTOR(width_b - 1 DOWNTO 0):= (OTHERS => '0');   
            address_a               : IN STD_LOGIC_VECTOR(widthad_a - 1 DOWNTO 0) := (OTHERS => '0');   
            address_b               : IN STD_LOGIC_VECTOR(widthad_b - 1 DOWNTO 0) := (OTHERS => '0');   
            -- two clocks only
            
            clock0                  : IN STD_LOGIC := '1';   
            clock1                  : IN STD_LOGIC := '1';   
            clocken0                : IN STD_LOGIC := '1';   
            clocken1                : IN STD_LOGIC := '1';   
            aclr0                   : IN STD_LOGIC := '0';   
            aclr1                   : IN STD_LOGIC := '0';   
            byteena_a               : IN STD_LOGIC_VECTOR( (width_byteena_a  - 1) DOWNTO 0) := (OTHERS => 'Z');   
            byteena_b               : IN STD_LOGIC_VECTOR( (width_byteena_b  - 1) DOWNTO 0) := (OTHERS => 'Z');   
              
            q_a                     : OUT STD_LOGIC_VECTOR(width_a - 1 DOWNTO 0);   
            q_b                     : OUT STD_LOGIC_VECTOR(width_b - 1 DOWNTO 0)
        );   
    END COMPONENT;



    COMPONENT LPM_COUNTER
        GENERIC 
        (
            LPM_WIDTH : natural;    -- MUST be greater than 0
            LPM_MODULUS : natural := 0;
            LPM_DIRECTION : string := "UNUSED";
            LPM_AVALUE : string := "UNUSED";
            LPM_SVALUE : string := "UNUSED";
            LPM_PVALUE : string := "UNUSED";
            LPM_TYPE: string := "LPM_COUNTER";
            LPM_HINT : string := "UNUSED"
        );
        PORT 
        (
            DATA : IN STD_LOGIC_VECTOR(LPM_WIDTH-1 DOWNTO 0):= (OTHERS => '0');
            CLOCK : IN STD_LOGIC ;
            CLK_EN : IN STD_LOGIC := '1';
            CNT_EN : IN STD_LOGIC := '1';
            UPDOWN : IN STD_LOGIC := '1';
            SLOAD : IN STD_LOGIC := '0';
            SSET : IN STD_LOGIC := '0';
            SCLR : IN STD_LOGIC := '0';
            ALOAD : IN STD_LOGIC := '0';
            ASET : IN STD_LOGIC := '0';
            ACLR : IN STD_LOGIC := '0';
            CIN : IN STD_LOGIC := '1';
            COUT : OUT STD_LOGIC := '0';
            Q : OUT STD_LOGIC_VECTOR(LPM_WIDTH-1 DOWNTO 0)
        );
    END COMPONENT;


    SIGNAL load_pc        : STD_LOGIC;
    SIGNAL pc_to_store    : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL pcw_from_store : STD_LOGIC_VECTOR( PCW_WIDTH-1 DOWNTO 0);
    SIGNAL pcw_from_store_int : STD_LOGIC_VECTOR( PCW_WIDTH-1 DOWNTO 0);
    
    SIGNAL d2a_jump_plus_one_out     : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d2a_jump_plus_one_reg_out : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d2a_inc                   : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d2a_pc_add_out                : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d2a_pc_reg_out            : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d2a_mux1_out              : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d2a_mux0_out              : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d2a_load_pc_d1                : STD_LOGIC;
    
    SIGNAL d0_next_pc_int : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d0_pc_int_0    : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    
    SIGNAL d1_next_pc_int : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d1_pc_int_0    : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d1_pc_int_1    : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    
    SIGNAL d2_pc_int_0    : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d2_pc_int_1    : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    
    SIGNAL d3_pc_int_0    : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d3_pc_int_1    : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d3_pc_int_2    : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    
    SIGNAL d2a_pc_int_0    : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d2a_pc_int_1    : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    SIGNAL d2a_pc_int_2    : STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0);
    
    SIGNAL ena_pc         : STD_LOGIC;
    
    SIGNAL pc_int         : STD_LOGIC_VECTOR( PC_WIDTH-1  DOWNTO 0);
    
    
    SIGNAL stall_d0       : STD_LOGIC;
    SIGNAL stall_d1       : STD_LOGIC;
    SIGNAL stall_d2       : STD_LOGIC;
    SIGNAL stall_d3       : STD_LOGIC;
    SIGNAL stall_int      : STD_LOGIC;
    SIGNAL stallnext_int  : STD_LOGIC;
    
    -- synopsys synthesis_off
    SIGNAL pc_int_d1      : STD_LOGIC_VECTOR( PC_WIDTH-1  DOWNTO 0);
    -- synopsys synthesis_on
BEGIN

     -- synopsys synthesis_off
    
    --watcher: process 
    --  variable rn : TTA_X_D_RN_T( 0 DOWNTO 0)  := 
    --      ( 
    --         new STRING'("pc"), 
    --         OTHERS => null
    --      );
    --  variable rv : TTA_X_D_RV_T( 0 DOWNTO 0)  := 
    --      ( 
    --          new STD_LOGIC_VECTOR(pc_int'high DOWNTO pc_int'low), 
    --          OTHERS => null
    --      );
    --begin
    --
    --  loop
    --    wait on pc_int;
    --    rv(0).all := pc_int;
    --    TTA_X_D_registerDump(NAME, rn, rv);
    --  end loop;
    --  --DEALLOCATE (rn(0));
    --  --DEALLOCATE (rv(0));
    --end process;
    
    debug : PROCESS (clock, reset)
      type string_ptr is access string;
      type string_ptr_array is array (PC_NUM_WORDS-1 DOWNTO 0) of string_ptr;
      variable opCodeVector : string_ptr_array;
      variable opVector     : string_ptr_array;
      variable opAddress    : string_ptr_array;
    
      variable dataLoaded : integer := 0;
    
      procedure loadData IS
        FILE f : text open read_mode is PROGRAM_TRACE;
        constant addressChars : INTEGER := (3+PC_WIDTH)/4;
        constant opCodeChars  : INTEGER := (3+PCW_WIDTH)/4;
        variable preamble : INTEGER ;
        variable address : STRING( addressChars  DOWNTO 1);
        variable opCode  : STRING( opCodeChars  DOWNTO 1);
        variable op      : string_ptr;
        variable padd    : character;
        variable l : line;
        variable i : integer;
      BEGIN
        preamble := addressChars + opCodeChars + 2;
        i := 0;
        while not endfile(f) and i /= PC_NUM_WORDS loop
          readline(f,l);
          read (l, address);
          read (l, padd);
          read (l, opCode);
          read (l, padd);
          op := new String(l.all'length DOWNTO 1);
          op.all := l.all;
          -- report "address="&address&" opCode="&opCode&" op="&op.all severity note;
    
          if (opAddress(i) /= null) then DEALLOCATE(opAddress(i)); end if;
          opAddress(i) := new String(addressChars DOWNTO 1);
          opAddress(i).all := address;
          
          if (opCodeVector(i) /= null) then DEALLOCATE(opCodeVector(i)); end if;
          opCodeVector(i) := new String(opCodeChars DOWNTO 1);
          opCodeVector(i).all := opCode;
          
          if (opVector(i) /= null) then DEALLOCATE(opVector(i)); end if;
          opVector(i) := op;
          
          i := i+1;
        end loop;
        dataLoaded := i;
      END;
    
      procedure reportState IS
        variable instruction : integer;
        
      BEGIN
        IF Is_X(pc_int_d1) THEN
          instruction := -1;
        ELSE
          instruction := to_integer(unsigned(pc_int_d1));
        END IF;
        
        if dataLoaded >= 1 then
          if instruction < 0 or instruction >= dataLoaded or instruction > PC_NUM_WORDS then
            TTA_X_D_registerTrace(  "??",
                                    "???????",
                                    "????????");
          else 
            TTA_X_D_registerTrace(  opAddress(instruction).all,
                                    opCodeVector(instruction).all,
                                    opVector(instruction).all );
          end if;    
        end if;
      END;
    
      BEGIN
        IF (reset = '1') THEN
          loadData;
        ELSIF clock'EVENT AND clock = '0' THEN
          IF (ena_pc = '1') THEN
            reportState;
          END IF;
        END IF;
      END PROCESS;
    
    
    delayed_pc: PROCESS(clock, reset)
      BEGIN
        IF (reset = '1') THEN
          pc_int_d1 <= (OTHERS=>'0');
        ELSIF clock'EVENT AND clock = '0' THEN
          IF (ena_pc = '1') THEN
            pc_int_d1 <= pc_int;
          END IF;
        END IF;
      END PROCESS;
    
    
     -- synopsys synthesis_on
    
    -- --------------------------------------------------------------------------------------------
    
    
    
    pc_echo: pc <= pc_int;
    load_pc_gen:  load_pc <= usenextpc AND usenextpc_en AND ena;
    --ena_pc_gen:   ena_pc  <= ena AND NOT ( hold and hold_en);
    ena_pc_gen:   ena_pc  <= (ena OR stall_int) AND NOT ( hold and hold_en);
    step_gen: step <= ena_pc;
    
    -----------------------------------------------------------------------------------------------
    --  Generate stall during reset and hold stall until first instruction is ready
    -----------------------------------------------------------------------------------------------
   
    stall_latency0_gen: IF (LATENCY = 1 or LATENCY = 2) GENERATE
        stall_d0 <= reset;
    END GENERATE;
    
    stallnext <= stallnext_int;
    
    
    stall_latency1_gen: IF (LATENCY = 1) GENERATE
        stall_int <= stall_d0;
        stallnext_int <= stall_d0;
    END GENERATE;
    
    stall_latency2_gen: IF (LATENCY = 2) GENERATE
        
        stall_int <= stall_d1;
        stallnext_int <= stall_d0;
        
        stall_d1_reg : PROCESS(reset, clock)
        BEGIN
           IF(reset = '1') THEN
              stall_d1 <= '1';
           ELSIF clock'EVENT AND clock = '1' THEN
              stall_d1 <= '0';
           END IF;
        END PROCESS;
    END GENERATE;
    
    
    stall_latency3_gen:  IF (LATENCY = 3) GENERATE
        
        stallnext_int <= stall_d1;
        stall_int <= stall_d2;
        
        stall_d1_reg : PROCESS(reset, clock)
        BEGIN
           IF(reset = '1') THEN
              stall_d1 <= '1';
           ELSIF clock'EVENT AND clock = '1' THEN
              stall_d1 <= '0';
           END IF;
        END PROCESS;
        
        stall_d2_reg : PROCESS(reset, clock)
        BEGIN
           IF(reset = '1') THEN
              stall_d2 <= '1';
           ELSIF clock'EVENT AND clock = '1' THEN
              stall_d2 <= stall_d1;
           END IF;
        END PROCESS;

    END GENERATE;
    
    
    stall_latency4_gen: IF (LATENCY = 4) GENERATE
        
        stallnext_int <= stall_d2;
        stall_int <= stall_d3;
        
        stall_d1_reg : PROCESS(reset, clock)
        BEGIN
           IF(reset = '1') THEN
              stall_d1 <= '1';
           ELSIF clock'EVENT AND clock = '1' THEN
              stall_d1 <= '0';
           END IF;
        END PROCESS;
        
        stall_d2_reg : PROCESS(reset, clock)
        BEGIN
           IF(reset = '1') THEN
              stall_d2 <= '1';
           ELSIF clock'EVENT AND clock = '1' THEN
              stall_d2 <= stall_d1;
           END IF;
        END PROCESS;
        
        stall_d3_reg : PROCESS(reset, clock)
        BEGIN
           IF(reset = '1') THEN
              stall_d3 <= '1';
           ELSIF clock'EVENT AND clock = '1' THEN
              stall_d3 <= stall_d2;
           END IF;
        END PROCESS;
        
        
    END GENERATE;
    
        d0: IF ( LATENCY = 1) GENERATE
        
            generate_next_pc_int : PROCESS (d0_pc_int_0, nextpc, load_pc)
            BEGIN
                IF ( load_pc = '1' ) THEN
                    d0_next_pc_int <= nextpc;
                ELSE
                    d0_next_pc_int <= std_logic_vector(UNSIGNED( d0_pc_int_0) + 1);
                END IF;
            END PROCESS;
            
            pc_to_store <= d0_next_pc_int; 

            pc_shadow_reg: PROCESS (clock, reset)
            BEGIN
                IF (reset = '1') THEN
                    d0_pc_int_0 <= (OTHERS=> '0');
                ELSIF clock'EVENT AND clock = '1' THEN
                    IF (ena_pc = '1') THEN
                        d0_pc_int_0 <= d0_next_pc_int;
                    END IF;
                END IF;
            END PROCESS;
            
            pc_int <= d0_pc_int_0;
            
           	pcf <= pc_to_store;
            	
        	d0check: IF ( DECODE_LATENCY /= 1 ) GENERATE
	            d0fail: ASSERT false REPORT "For LATENCY=1 DECODE_LATENCY is 1" SEVERITY Failure;
	        END GENERATE; -- error check
          
	        d0_explicit: IF (INFER_MEMORY = 0) GENERATE
            
	            altsyncram_component : altsyncram
	            GENERIC MAP 
	            (
	                operation_mode => "ROM",
	                width_a => PCW_WIDTH,
	                widthad_a => PC_WIDTH,
	                numwords_a => PC_NUM_WORDS,
	                lpm_type => "altsyncram",
	                width_byteena_a => 1,
	                outdata_reg_a => "UNREGISTERED",
	                outdata_aclr_a => "NONE",
	                address_aclr_a => "CLEAR0",
	                read_during_write_mode_mixed_ports => "DONT_CARE",
	                ram_block_type => "AUTO",
	                init_file => PROGRAM_FILE,
	                intended_device_family => "Stratix"
	            )
	            PORT MAP 
	            (
	                clocken0 => ena_pc,
	                aclr0 => reset,
	                clock0 => clock,
	                address_a => pc_to_store,
	                q_a => pcw_from_store
	            );
	            
	            pcw <= pcw_from_store;

            END GENERATE; -- not INFER
	        
        END GENERATE; -- ALTERA LATENCY=1
        -- --------------------------------------------------------------------------------------------
        
        -- --------------------------------------------------------------------------------------------
        d1: if ( LATENCY = 2) GENERATE
            generate_next_pc_int : PROCESS (d1_pc_int_0, nextpc, load_pc)
            BEGIN
                IF ( load_pc = '1') THEN
                    d1_next_pc_int <= nextpc;
                ELSE
                    d1_next_pc_int <= std_logic_vector(UNSIGNED( d1_pc_int_0) + 1);
                END IF;
            END PROCESS;
          
            pc_to_store <= d1_next_pc_int; 
          
        	d1check: IF ( DECODE_LATENCY /= 2 ) GENERATE
	            d1fail: ASSERT false REPORT "For LATENCY=2 DECODE_LATENCY is 2" SEVERITY Failure;
	        END GENERATE; -- error check
          
	        pc_shadow_reg_0: PROCESS (clock, reset)  -- shadow of RAM input register
	        BEGIN
	            IF (reset = '1') THEN
	                d1_pc_int_0 <= (OTHERS=> '0');
	            ELSIF clock'EVENT AND clock = '1' THEN
	                IF (ena_pc = '1') THEN
	                    d1_pc_int_0 <= pc_to_store;
	                END IF;
	            END IF;
	        END PROCESS;
	          
	        pc_shadow_reg_1: PROCESS (clock, reset) -- shadow or RAM output register
	        BEGIN
	            IF (reset = '1') THEN
	                d1_pc_int_1 <= (OTHERS=> '0');
	            ELSIF clock'EVENT AND clock = '1' THEN
	                IF (ena_pc = '1') THEN
	                    d1_pc_int_1 <= d1_pc_int_0;
	                END IF;
	            END IF;
	        END PROCESS;
	        
	        pc_int <= d1_pc_int_1;
	        
            pcf <= pc_to_store;
            	
	        d1_explicit: IF (INFER_MEMORY = 0) GENERATE
            
                altsyncram_component : altsyncram
                GENERIC MAP
				(
                    operation_mode => "ROM",
		            width_a => PCW_WIDTH,
		            widthad_a => PC_WIDTH,
		            numwords_a => PC_NUM_WORDS,
		            lpm_type => "altsyncram",
		            width_byteena_a => 1,
		            outdata_reg_a => "CLOCK0",
		            outdata_aclr_a => "CLEAR0",
		            address_aclr_a => "CLEAR0",
		            read_during_write_mode_mixed_ports => "DONT_CARE",
		            ram_block_type => "AUTO",
		            init_file => PROGRAM_FILE,
		            intended_device_family => "Stratix"
		        )
          		PORT MAP (
		            clocken0 => ena_pc,
		            aclr0 => reset,
		            clock0 => clock,
		            address_a => pc_to_store,
		            q_a => pcw_from_store
				);

				pcw <= pcw_from_store; 
				
            END GENERATE; -- not INFER
	        
        END GENERATE; -- ALTERA LATENCY=2
        -- --------------------------------------------------------------------------------------------
        
        -- --------------------------------------------------------------------------------------------
        d2: if ( LATENCY = 3) GENERATE
          
            lpm_counter_component : lpm_counter
            GENERIC MAP (
            	lpm_width => PC_WIDTH,
	            lpm_type => "LPM_COUNTER",
	            lpm_direction => "UP",
	            lpm_avalue => "0"
			)
			PORT MAP (
	            sload => load_pc,
	            clk_en => ena_pc,
	            clock => clock,
	            data => nextpc,
	            aset => reset,
	            q => pc_to_store
			);

        	d2check: IF ( DECODE_LATENCY /= 2 ) GENERATE
	            d2fail: ASSERT false REPORT "For LATENCY=3 DECODE_LATENCY is 2" SEVERITY Failure;
	        END GENERATE; -- error check
          
          	pc_shadow_reg_0: PROCESS (clock, reset)  -- shadow of RAM input register
      		BEGIN
        		IF (reset = '1') THEN
          			d2_pc_int_0 <= (OTHERS=> '0');
            	ELSIF clock'EVENT AND clock = '1' THEN
	          		IF (ena_pc = '1') THEN
    	        		d2_pc_int_0 <= pc_to_store;
        		  	END IF;
        		END IF;
          	END PROCESS;
          
          	pc_shadow_reg_1: PROCESS (clock, reset) -- shadow or RAM output register
          	BEGIN
            	IF (reset = '1') THEN
              		d2_pc_int_1 <= (OTHERS=> '0');
				ELSIF clock'EVENT AND clock = '1' THEN
              		IF (ena_pc = '1') THEN
                		d2_pc_int_1 <= d2_pc_int_0;
              		END IF;
            	END IF;
          	END PROCESS;
          
          	pc_int <= d2_pc_int_1;

            pcf <= pc_to_store;
            	
	        d2_explicit: IF (INFER_MEMORY = 0) GENERATE

			  	altsyncram_component : altsyncram
				GENERIC MAP (
				    operation_mode => "ROM",
				    width_a => PCW_WIDTH,
				    widthad_a => PC_WIDTH,
				    numwords_a => PC_NUM_WORDS,
				    lpm_type => "altsyncram",
				    width_byteena_a => 1,
				    outdata_reg_a => "CLOCK0",
				    outdata_aclr_a => "CLEAR0",
				    address_aclr_a => "CLEAR0",
				    read_during_write_mode_mixed_ports => "DONT_CARE",
				    ram_block_type => "AUTO",
				    init_file => PROGRAM_FILE,
				    intended_device_family => "Stratix"
				)
				PORT MAP (
				    clocken0 => ena_pc,
				    aclr0 => reset,
				    clock0 => clock,
				    address_a => pc_to_store,
				    q_a => pcw_from_store
				);
			  
				pcw <= pcw_from_store; 
			
			END GENERATE; -- not INFER
			
        end GENERATE; -- ALTERA LATENCY=3
        -- --------------------------------------------------------------------------------------------
        
        -- --------------------------------------------------------------------------------------------
--        d2a: if ( LATENCY = 31) GENERATE -- This is the 3a case
--         
--          jump_plus_one : PROCESS(nextpc)
--          BEGIN
--             d2a_jump_plus_one_out <= std_logic_vector(UNSIGNED(nextpc) + 1);
--          END PROCESS;
--          
--          jump_plus_one_reg : PROCESS(clock, reset)
--          BEGIN
--             IF(reset = '1') THEN
--                d2a_jump_plus_one_reg_out <= (OTHERS=>'0');
--             ELSIF (clock'EVENT AND clock = '1') THEN
--                IF (ena_pc = '1') THEN
--                   IF (load_pc = '1') THEN -- can get rid of this conditional if that improves fmax
--                      d2a_jump_plus_one_reg_out <= d2a_jump_plus_one_out;
--                   ELSE
--                      d2a_jump_plus_one_reg_out <= d2a_jump_plus_one_reg_out;
--                   END IF;
--                END IF; 
--             END IF;
--          END PROCESS;
--          
--          pc_inc_mux : PROCESS(d2a_load_pc_d1)
--          BEGIN
--             IF(d2a_load_pc_d1 = '1') THEN
--                d2a_inc <= std_logic_vector(TO_UNSIGNED(2, PC_WIDTH));
--             ELSE
--                d2a_inc <= std_logic_vector(TO_UNSIGNED(1, PC_WIDTH));
--             END IF;
--          END PROCESS;
--          
--          pc_add : PROCESS (d2a_pc_reg_out, d2a_inc)
--          BEGIN
--             d2a_pc_add_out <= std_logic_vector(UNSIGNED(d2a_pc_reg_out) + UNSIGNED(d2a_inc));
--          END PROCESS;
--          
--          pc_reg : PROCESS (clock, reset)
--          BEGIN
--             IF(reset = '1') THEN
--                d2a_pc_reg_out <= (OTHERS=>'0');
--             ELSIF (clock'EVENT AND clock = '1') THEN
--                IF (ena_pc = '1') THEN
--                   IF (load_pc = '1') THEN
--                      d2a_pc_reg_out <= nextpc;
--                   ELSE
--                      d2a_pc_reg_out <= d2a_pc_add_out;
--                   END IF;
--                END IF;
--             END IF;
--          END PROCESS;
--          
--          load_pc_d1_reg : PROCESS (clock, reset)
--          BEGIN
--             IF(reset = '1') THEN
--                d2a_load_pc_d1 <= '0';
--             ELSIF (clock'EVENT AND clock = '1') THEN
--                IF (ena_pc = '1') THEN
--                   d2a_load_pc_d1 <= load_pc;
--                END IF;
--             END IF;  
--          END PROCESS;
--          
--          mux0 : PROCESS (d2a_load_pc_d1, d2a_pc_reg_out, d2a_jump_plus_one_reg_out)
--          BEGIN
--             IF(d2a_load_pc_d1 = '1') THEN
--                d2a_mux0_out <= d2a_jump_plus_one_reg_out;
--             ELSE
--                d2a_mux0_out <= d2a_pc_reg_out;
--             END IF;
--          END PROCESS;
--         
--          mux1 : PROCESS (load_pc, nextpc, d2a_mux0_out)
--          BEGIN
--             IF(load_pc = '1') THEN
--                d2a_mux1_out <= nextpc;
--             ELSE
--                d2a_mux1_out <= d2a_mux0_out;
--             END IF;
--          END PROCESS;
--          
--          pc_to_store <= d2a_mux1_out;
--          
--          pc_shadow_reg_0: PROCESS (clock, reset)  -- shadow of RAM input register
--          BEGIN
--            IF (reset = '1') THEN
--              d2a_pc_int_0 <= (OTHERS=> '0');
--            ELSIF clock'EVENT AND clock = '1' THEN
--              IF (ena_pc = '1') THEN
--                d2a_pc_int_0 <= pc_to_store;
--              END IF;
--            END IF;
--          END PROCESS;
--          
--          pc_shadow_reg_1: PROCESS (clock, reset) -- shadow or RAM output register
--          BEGIN
--            IF (reset = '1') THEN
--              d2a_pc_int_1 <= (OTHERS=> '0');
--            ELSIF clock'EVENT AND clock = '1' THEN
--              IF (ena_pc = '1') THEN
--                d2a_pc_int_1 <= d2a_pc_int_0;
--              END IF;
--            END IF;
--          END PROCESS;
--          
--          pc_shadow_reg_2: PROCESS (clock, reset) -- shadow of second RAM output register
--          BEGIN
--            IF (reset = '1') THEN
--              d2a_pc_int_2 <= (OTHERS=> '0');
--            ELSIF clock'EVENT AND clock = '1' THEN
--              IF (ena_pc = '1') THEN
--                d2a_pc_int_2 <= d2a_pc_int_1;
--              END IF;
--            END IF;
--          END PROCESS;
--          
--          pc_int <= d2a_pc_int_2;
--          
--          altsyncram_component : altsyncram
--          GENERIC MAP (
--            operation_mode => "ROM",
--            width_a => PCW_WIDTH,
--            widthad_a => PC_WIDTH,
--            numwords_a => PC_NUM_WORDS,
--            lpm_type => "altsyncram",
--            width_byteena_a => 1,
--            outdata_reg_a => "CLOCK0",
--            outdata_aclr_a => "CLEAR0",
--            address_aclr_a => "CLEAR0",
--            read_during_write_mode_mixed_ports => "DONT_CARE",
--            ram_block_type => "AUTO",
--            init_file => PROGRAM_FILE,
--            intended_device_family => "Stratix"
--          )
--          PORT MAP (
--            clocken0 => ena_pc,
--            aclr0 => reset,
--            clock0 => clock,
--            address_a => pc_to_store,
--            q_a => pcw_from_store_int
--          );
--          
--          pcw_reg: PROCESS (clock, reset) -- second RAM output register
--          BEGIN
--            IF (reset = '1') THEN
--              pcw_from_store <= (OTHERS=> '0');
--            ELSIF clock'EVENT AND clock = '1' THEN
--              IF (ena_pc = '1') THEN
--                 pcw_from_store <= pcw_from_store_int;
--              END IF;
--            END IF;
--          END PROCESS;
--          
--          pcw <= pcw_from_store;
--        end GENERATE; -- ALTERA LATENCY=3(derivative)
        -- --------------------------------------------------------------------------------------------
        
        -- --------------------------------------------------------------------------------------------
        d3: if ( LATENCY = 4) GENERATE
          
          	lpm_counter_component : lpm_counter
          	GENERIC MAP (
            	lpm_width => PC_WIDTH,
	            lpm_type => "LPM_COUNTER",
	            lpm_direction => "UP",
	            lpm_avalue => "0"
	        )
	        PORT MAP (
	            sload => load_pc,
	            clk_en => ena_pc,
	            clock => clock,
	            data => nextpc,
	            aset => reset,
	            q => pc_to_store
	        );

        	d3check: IF ( DECODE_LATENCY /= 3 ) GENERATE
	            d3fail: ASSERT false REPORT "For LATENCY=4 DECODE_LATENCY is 3" SEVERITY Failure;
	        END GENERATE; -- error check
          
          	pc_shadow_reg_0: PROCESS (clock, reset)  -- shadow of RAM input register
          	BEGIN
            	IF (reset = '1') THEN
              		d3_pc_int_0 <= (OTHERS=> '0');
            	ELSIF clock'EVENT AND clock = '1' THEN
              		IF (ena_pc = '1') THEN
                		d3_pc_int_0 <= pc_to_store;
              		END IF;
            	END IF;
          	END PROCESS;
          
          	pc_shadow_reg_1: PROCESS (clock, reset) -- shadow of RAM output register
          	BEGIN
            	IF (reset = '1') THEN
              		d3_pc_int_1 <= (OTHERS=> '0');
            	ELSIF clock'EVENT AND clock = '1' THEN
              		IF (ena_pc = '1') THEN
                		d3_pc_int_1 <= d3_pc_int_0;
              		END IF;
            	END IF;
          	END PROCESS;
          
          	pc_shadow_reg_2: PROCESS (clock, reset) -- shadow of second RAM output register
          	BEGIN
            	IF (reset = '1') THEN
              		d3_pc_int_2 <= (OTHERS=> '0');
            	ELSIF clock'EVENT AND clock = '1' THEN
              		IF (ena_pc = '1') THEN
                		d3_pc_int_2 <= d3_pc_int_1;
              		END IF;
            	END IF;
          	END PROCESS;
          
          	pc_int <= d3_pc_int_2;

            pcf <= pc_to_store;
            	
	        d3_explicit: IF (INFER_MEMORY = 0) GENERATE

			  	altsyncram_component : altsyncram
			  	GENERIC MAP (
				    operation_mode => "ROM",
				    width_a => PCW_WIDTH,
				    widthad_a => PC_WIDTH,
				    numwords_a => PC_NUM_WORDS,
				    lpm_type => "altsyncram",
				    width_byteena_a => 1,
				    outdata_reg_a => "CLOCK0",
				    outdata_aclr_a => "CLEAR0",
				    address_aclr_a => "CLEAR0",
				    read_during_write_mode_mixed_ports => "DONT_CARE",
				    ram_block_type => "AUTO",
				    init_file => PROGRAM_FILE,
				    intended_device_family => "Stratix"
				)
				PORT MAP (
				    clocken0 => ena_pc,
				    aclr0 => reset,
				    clock0 => clock,
				    address_a => pc_to_store,
				    q_a => pcw_from_store_int
				);
          
			  	pcw_reg: PROCESS (clock, reset) -- second RAM output register
			  	BEGIN
			    	IF (reset = '1') THEN
			      		pcw_from_store <= (OTHERS=> '0');
			    	ELSIF clock'EVENT AND clock = '1' THEN
			      		IF (ena_pc = '1') THEN
			        		pcw_from_store <= pcw_from_store_int;      
			      		END IF;
			    	END IF;
			  	END PROCESS;
			  
			  	pcw <= pcw_from_store; 

			END GENERATE; -- not INFER          	
          	
        end GENERATE; -- ALTERA LATENCY=4
        
        dx: IF ( LATENCY > 4 AND LATENCY /= 31 ) GENERATE
            unsupported_mode: ASSERT false REPORT "Delay slot parameter not suppported by PC" SEVERITY Failure;
        END GENERATE; -- error check

	-- Tie off unused outputs
	all_infer: IF (INFER_MEMORY /= 0) GENERATE
       pcw <= (others => '0');
	END GENERATE; -- INFER

END ARCHITECTURE;

