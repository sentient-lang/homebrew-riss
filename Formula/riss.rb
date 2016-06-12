class Riss < Formula
  desc "The SAT Solving Package Riss"
  homepage "http://tools.computational-logic.org/content/riss.php"

  stable do
    url "http://tools.computational-logic.org/content/riss/Riss.tar.gz"
    version "4.27"
    sha256 "8d7955193d31155f1e2c4ffba3af68033baceaf5c4fb7272e32b1b310e3d2573"

    patch :DATA
  end

  def install
    system "make"
    system "make", "coprocessorRS"
    bin.install "riss", "coprocessor"
  end

  test do
    system "riss", "--help"
  end
end

__END__
From efc06ffab5435b4686f3889167a7d5260de4e1fe Mon Sep 17 00:00:00 2001
From: Chris Patuzzo <chris@patuzzo.co.uk>
Date: Mon, 30 May 2016 11:59:11 +0100
Subject: [PATCH 1/1] Port Riss 4.27 and Coprocessor to Mac OS X

---
 Makefile                                              |  5 ++---
 coprocessor-src/BoundedVariableEliminationParallel.cc |  2 +-
 coprocessor-src/Coprocessor.cc                        |  9 +--------
 coprocessor-src/Coprocessor.h                         | 12 +++++-------
 coprocessor-src/FourierMotzkin.cc                     |  1 -
 core/SolverTypes.h                                    |  4 ++--
 mtl/template.mk                                       |  1 -
 utils/AutoDelete.h                                    |  2 +-
 8 files changed, 12 insertions(+), 24 deletions(-)

diff --git a/Makefile b/Makefile
index edfc81f..1b720c4 100644
--- a/Makefile
+++ b/Makefile
@@ -8,9 +8,8 @@
 CORE      = ../core
 MTL       = ../mtl
 VERSION   = 
-MYCFLAGS  = -I.. -I. -I$(MTL) -I$(CORE) $(ARGS) -Wall -Wextra -ffloat-store -Wno-unused-but-set-variable -Wno-unused-variable -Wno-unused-parameter -Wno-sign-compare -Wno-parentheses $(VERSION)
-LIBRT     = -lrt
-MYLFLAGS  = -lpthread $(LIBRT) $(ARGS)
+MYCFLAGS  = -I.. -I. -I$(MTL) -I$(CORE) $(ARGS) -Wno-unused-variable -Wno-unused-parameter -Wno-sign-compare -Wno-parentheses -Wno-format -Wno-deprecated-declarations -Wno-unused-comparison -Wno-shift-overflow -Wno-tautological-constant-out-of-range-compare $(VERSION)
+MYLFLAGS  = -lpthread $(ARGS)
 
 COPTIMIZE ?= -O3
 
diff --git a/coprocessor-src/BoundedVariableEliminationParallel.cc b/coprocessor-src/BoundedVariableEliminationParallel.cc
index abf084d..761708a 100644
--- a/coprocessor-src/BoundedVariableEliminationParallel.cc
+++ b/coprocessor-src/BoundedVariableEliminationParallel.cc
@@ -1017,7 +1017,7 @@ void BoundedVariableElimination::parallelBVE(CoprocessorData& data)
   Heap<VarOrderBVEHeapLt> newheap(comp);
 #ifdef __APPLE__
   BVEWorkData *workData=new BVEWorkData[ controller.size() ];
-  MethodFree mf(workData);
+  MethodFree mf((void*&)workData);
 #else
   BVEWorkData workData[ controller.size() ];
 #endif
diff --git a/coprocessor-src/Coprocessor.cc b/coprocessor-src/Coprocessor.cc
index 46dfe7f..53b2aa7 100644
--- a/coprocessor-src/Coprocessor.cc
+++ b/coprocessor-src/Coprocessor.cc
@@ -42,7 +42,6 @@ config( _config )
 , rate  ( config, solver->ca, controller, data, *solver, propagation )
 , res( config, solver->ca, controller, data,propagation)
 , rew( config, solver->ca, controller, data, subsumption )
-, fourierMotzkin( config, solver->ca, controller, data, propagation, *solver )
 , dense( config, solver->ca, controller, data, propagation)
 , symmetry(config, solver->ca, controller, data, *solver)
 , xorReasoning(config, solver->ca, controller, data, propagation, ee )
@@ -216,8 +215,7 @@ lbool Preprocessor::performSimplification()
     if( config.opt_FM ) {
       if( config.opt_verbose > 0 ) cerr << "c FM ..." << endl;
       if( config.opt_verbose > 4 )cerr << "c coprocessor(" << data.ok() << ") fourier motzkin" << endl;
-      if( status == l_Undef ) fourierMotzkin.process();  // cannot change status, can generate new unit clauses
-      if( config.opt_verbose > 1 )  { printStatistics(cerr); fourierMotzkin.printStatistics(cerr); }
+      if( config.opt_verbose > 1 )  { printStatistics(cerr); }
       if (! data.ok() )
 	  status = l_False;
       data.checkGarbage(); // perform garbage collection
@@ -519,7 +517,6 @@ lbool Preprocessor::performSimplification()
     if( config.opt_rate ) rate.printStatistics(cerr);
     if( config.opt_ent ) entailedRedundant.printStatistics(cerr);
     if( config.opt_rew ) rew.printStatistics(cerr);
-    if( config.opt_FM ) fourierMotzkin.printStatistics(cerr);
     if( config.opt_dense ) dense.printStatistics(cerr);
     if( config.opt_symm ) symmetry.printStatistics(cerr);
   }
@@ -818,8 +815,6 @@ lbool Preprocessor::performSimplificationScheduled(string techniques)
     // fourier motzkin "f"
     else if( execute == 'f' && config.opt_FM && status == l_Undef && data.ok() ) {
 	if( config.opt_verbose > 2 ) cerr << "c fm" << endl;
-	fourierMotzkin.process();
-	change = fourierMotzkin.appliedSomething() || change;
 	if( config.opt_verbose > 1 ) cerr << "c FM changed formula: " << change << endl;
     }
     
@@ -976,7 +971,6 @@ lbool Preprocessor::performSimplificationScheduled(string techniques)
     if( config.opt_rate ) rate.printStatistics(cerr);
     if( config.opt_ent ) entailedRedundant.printStatistics(cerr);
     if( config.opt_rew ) rew.printStatistics(cerr);
-    if( config.opt_FM ) fourierMotzkin.printStatistics(cerr);
     if( config.opt_dense ) dense.printStatistics(cerr);
     if( config.opt_symm ) symmetry.printStatistics(cerr);
   }
@@ -1096,7 +1090,6 @@ void Preprocessor::giveMoreSteps()
   probing.giveMoreSteps();
   res.giveMoreSteps();
   rew.giveMoreSteps();
-  fourierMotzkin.giveMoreSteps();
 }
 
 lbool Preprocessor::preprocessScheduled()
diff --git a/coprocessor-src/Coprocessor.h b/coprocessor-src/Coprocessor.h
index 02a1e40..80fd25a 100644
--- a/coprocessor-src/Coprocessor.h
+++ b/coprocessor-src/Coprocessor.h
@@ -3,7 +3,7 @@ Copyright (c) 2012, Norbert Manthey, All rights reserved.
 **************************************************************************************************/
 
 #ifndef COPROCESSOR_HH
-#define COPRECESSOR_HH
+#define COPROCESSOR_HH
 
 
 #include "core/Solver.h"
@@ -25,7 +25,6 @@ Copyright (c) 2012, Norbert Manthey, All rights reserved.
 #include "coprocessor-src/Probing.h"
 #include "coprocessor-src/Resolving.h"
 #include "coprocessor-src/Rewriter.h"
-#include "coprocessor-src/FourierMotzkin.h"
 #include "coprocessor-src/bce.h"
 #include "coprocessor-src/LiteralAddition.h"
 #include "coprocessor-src/xor.h"
@@ -161,23 +160,22 @@ protected:
   RATElimination rate;
   Resolving res;
   Rewriter rew;
-  FourierMotzkin fourierMotzkin;
   Dense dense;
   Symmetry symmetry;
   XorReasoning xorReasoning;
   BlockedClauseElimination bce;
   LiteralAddition la;
   EntailedRedundant entailedRedundant;
-  
+
   Sls sls;
   TwoSatSolver twoSAT;
-  
+
   int shuffleVariable;  // number of variables that have been present when the formula has been shuffled
-  
+
   // do the real work
   lbool performSimplification();
   void printStatistics(ostream& stream);
-  
+
   // own methods:
   void cleanSolver();                // remove all clauses from structures inside the solver
   void reSetupSolver();              // add all clauses back into the solver, remove clauses that can be deleted
diff --git a/coprocessor-src/FourierMotzkin.cc b/coprocessor-src/FourierMotzkin.cc
index 3c9ad6e..81de8e3 100644
--- a/coprocessor-src/FourierMotzkin.cc
+++ b/coprocessor-src/FourierMotzkin.cc
@@ -4,7 +4,6 @@ Copyright (c) 2013, Norbert Manthey, All rights reserved.
 
 #include "coprocessor-src/FourierMotzkin.h"
 #include "mtl/Sort.h"
-#include <bits/algorithmfwd.h>
 
 
 using namespace Coprocessor;
diff --git a/core/SolverTypes.h b/core/SolverTypes.h
index f07b7d6..2161d73 100644
--- a/core/SolverTypes.h
+++ b/core/SolverTypes.h
@@ -67,7 +67,7 @@ struct Lit {
     int     x;
 
     // Use this as a constructor:
-    friend Lit mkLit(Var var, bool sign = false);
+    Lit mkLit(Var var, bool sign);
 
     bool operator == (Lit p) const { return x == p.x; }
     bool operator != (Lit p) const { return x != p.x; }
@@ -77,7 +77,7 @@ struct Lit {
 };
 
 
-inline  Lit  mkLit     (Var var, bool sign) { Lit p; p.x = var + var + (int)sign; return p; }
+inline  Lit  mkLit     (Var var, bool sign = false) { Lit p; p.x = var + var + (int)sign; return p; }
 inline  Lit  operator ~(Lit p)              { Lit q; q.x = p.x ^ 1; return q; }
 inline  Lit  operator ^(Lit p, bool b)      { Lit q; q.x = p.x ^ (unsigned int)b; return q; }
 inline  bool sign      (Lit p)              { return p.x & 1; }
diff --git a/mtl/template.mk b/mtl/template.mk
index 71024ed..252e95d 100644
--- a/mtl/template.mk
+++ b/mtl/template.mk
@@ -55,7 +55,6 @@ $(EXEC):		LFLAGS += -g
 $(EXEC)_profile:	LFLAGS += -g -pg
 $(EXEC)_debug:		LFLAGS += -g
 #$(EXEC)_release:	LFLAGS += ...
-$(EXEC)_static:		LFLAGS += --static
 
 ## Dependencies
 $(EXEC):		$(COBJS)
diff --git a/utils/AutoDelete.h b/utils/AutoDelete.h
index f9427e0..872f175 100644
--- a/utils/AutoDelete.h
+++ b/utils/AutoDelete.h
@@ -12,7 +12,7 @@ OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWA
 #ifndef AUTODELETE_H
 #define AUTODELETE_H
 
-#include <malloc.h>
+#include <malloc/malloc.h>
 
 /** this object frees a pointer before a method /statementblock is left */
 class MethodFree {
-- 
2.6.4 (Apple Git-63)
