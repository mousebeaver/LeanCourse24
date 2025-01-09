import Mathlib
import LeanCourse.Project.leanCode.RepresentationHom

/- open namespaces that you use to shorten names and enable notation. -/
open Function Set Classical Representation
noncomputable section

theorem representationIrreducibility_equiv_simpleModule {k G V : Type*} [CommRing k] [Monoid G] [AddCommGroup V] [Module k V] [Nontrivial V] [Finite G]
  (ρ : Representation k G V) : ρ.IsIrreducible ↔ IsSimpleModule (MonoidAlgebra k G) ρ.asModule:= by{
  constructor
  . sorry/-intro h
    refine isSimpleOrder_iff_isAtom_top.mpr ?mp.a
    /- Proof by contradiction-/
    by_contra ct

    /- There is a proper submodule over kG-/
    have h' : ∃ U : (Submodule (MonoidAlgebra k G) ρ.asModule), U ≠ ⊥ ∧ U ≠ ⊤ := by {
      have defAtom : ¬ (⊤ ≠ (⊥ : (Submodule (MonoidAlgebra k G) ρ.asModule)) ∧
        ∀ W : (Submodule (MonoidAlgebra k G) ρ.asModule), W ≠ ⊥ → W ≤ ⊤ → ⊤ ≤ W) := by{
          by_contra tc
          have ct' : IsAtom (⊤ : (Submodule (MonoidAlgebra k G) ρ.asModule)) := by
            exact isAtom_iff_le_of_ge.mpr tc
          contradiction
        }
      push_neg at defAtom
      have top_neq_bot : ⊤ ≠ (⊥ : (Submodule (MonoidAlgebra k G) ρ.asModule)) := by
        refine (Submodule.ne_bot_iff ⊤).mpr ?_
        have nontrV : ∃ x : V, x ≠ 0 := by exact exists_ne 0
        have nontrAsModule : ∃ x : ρ.asModule, x ≠ 0 := by
          obtain ⟨x, hx⟩ := nontrV
          use x
        obtain ⟨x, hx⟩ := nontrAsModule
        use x
        constructor
        . exact _root_.trivial
        . assumption
      specialize defAtom top_neq_bot
      obtain ⟨W, hW⟩ := defAtom
      use W
      constructor
      . exact hW.left
      . obtain ⟨_, ⟨_, hW⟩⟩ := hW
        simp at hW
        assumption
    }
    obtain ⟨U, hU⟩ := h'

    /- ρ.asModuleEquiv translates elements!!!-/

    have ht : ¬ρ.IsIrreducible := by{
      unfold Representation.IsIrreducible
      push_neg

      let U' : Submodule k V := ⟨⟨⟨U.carrier, by{
        simp
        intro a b aU bU
        exact (Submodule.add_mem_iff_right U aU).mpr bU
      }⟩, by{
        simp
      }⟩, by{
        simp
        intro c v vU
        let v' : ρ.asModule := v
        have transModuleAlgebra : c • v = ρ.asModuleEquiv ((MonoidAlgebra.single (1 : G) c) • v') := by
          symm
          calc
            ρ.asModuleEquiv ((MonoidAlgebra.single (1 : G) c) • v') = (ρ.asAlgebraHom (MonoidAlgebra.single (1 : G) c)) (ρ.asModuleEquiv v') := by rfl
            _ = (ρ.asAlgebraHom (MonoidAlgebra.single (1 : G) c)) v := by rfl
            _ = (c • ρ (1 : G)) v := by rw [asAlgebraHom_single]
            _ = c • ((ρ 1) v) := by rfl
            _ = c • ((1 : V →ₗ[k] V) v) := by rw [MonoidHom.map_one ρ]
            _ = c • v := by simp
        rw [transModuleAlgebra]
        exact Submodule.smul_mem U (MonoidAlgebra.single 1 c) vU
      }⟩
      use U'
      have U'Car : U'.carrier = U.carrier := by rfl
      have botCar : (⊥ : Submodule k V).carrier = {0} := by rfl
      constructor
      . simp [IsInvariantSubspace]
        intro g u uU'
        let u' : ρ.asModule := u
        /- This should become its own lemma!!! TODO-/
        have transReprAlgebra : (ρ g) u = ρ.asModuleEquiv (((MonoidAlgebra.single) g (1 : k)) • u') := by
          symm
          calc
            ρ.asModuleEquiv (((MonoidAlgebra.single) g (1 : k)) • u') = (ρ.asAlgebraHom ((MonoidAlgebra.single) g (1 : k))) (ρ.asModuleEquiv u') := by rfl
            _ = (ρ.asAlgebraHom ((MonoidAlgebra.single) g (1 : k))) u := by rfl
            _ = (ρ g) u := by refine LinearMap.congr_fun ?h u; exact asAlgebraHom_single_one ρ g
        rw [transReprAlgebra]
        have showAsCar : (((MonoidAlgebra.single) g (1 : k)) • u') ∈ U'.carrier := by
          rw [U'Car]
          have smulInModule : (((MonoidAlgebra.single) g (1 : k)) • u') ∈ U := by{
            exact Submodule.smul_mem U (MonoidAlgebra.single g 1) uU'
          }
          assumption
        assumption

      . constructor
        /- Refactor this part using ext-/
        . by_contra t
          have uZero : ∀ u : U, u = 0 := by
            intro u
            simp at t
            by_contra t'
            have UneBot : U' ≠ ⊥ := by
              have carComp : U'.carrier ≠ (⊥ : Submodule k V).carrier := by
                rw [botCar, U'Car]
                by_contra t''
                have uBot : U = ⊥ := by
                  ext z
                  constructor
                  . intro zU
                    refine (Submodule.mem_bot (MonoidAlgebra k G)).mpr ?h.mp.a
                    have zCar : z ∈ U.carrier := by exact zU
                    rw [t''] at zCar
                    simp at zCar
                    assumption
                  . intro zBot
                    simp at zBot
                    rw [zBot]
                    exact Submodule.zero_mem U
                obtain ⟨hU, _⟩ := hU
                contradiction
              exact
                False.elim
                  (carComp
                    (congrArg AddSubsemigroup.carrier
                      (congrArg AddSubmonoid.toAddSubsemigroup
                        (congrArg Submodule.toAddSubmonoid t))))
            contradiction
          have uBot : U = ⊥ := by
            rw [← Submodule.zero_eq_bot]
            refine Eq.symm (Submodule.ext ?hyp)
            intro v
            constructor
            . intro v0
              simp at v0
              rw [v0]
              exact Submodule.zero_mem U
            . intro vU
              let v' : U := ⟨v, vU⟩
              specialize uZero v'
              simp
              by_contra t'
              have t'' : v' ≠ 0 := by
                exact Subtype.coe_ne_coe.mp t'
              contradiction
          obtain ⟨hU, _⟩ := hU
          contradiction
        . by_contra t
          have uTop : U = ⊤ := by
            ext x
            constructor
            . intro xU
              exact _root_.trivial
            . intro xTop
              have xUCar : x ∈ U.carrier := by
                rw [← U'Car]
                have carComp : U'.carrier = (⊤ : Submodule k V).carrier := by
                  exact
                    congrArg AddSubsemigroup.carrier
                      (congrArg AddSubmonoid.toAddSubsemigroup
                        (congrArg Submodule.toAddSubmonoid t))
                rw [carComp]
                simp
              exact xUCar
          obtain ⟨_, hU⟩ := hU
          contradiction
    }
    contradiction-/
  . intro h
    unfold Representation.IsIrreducible
    intro U hU

    /-translate to a kG-Module-/
    let U' : Submodule (MonoidAlgebra k G) ρ.asModule := ⟨⟨⟨U.carrier, by {
      simp
      intro a b aU bU
      exact (Submodule.add_mem_iff_right U aU).mpr bU
    }⟩, by {
      simp
    }⟩, by{
      simp
      intro r x xU
      rw [← MonoidAlgebra.sum_single r]
      have asFinSum : Finsupp.sum r MonoidAlgebra.single • x = (∑ g ∈ r.support, MonoidAlgebra.single g (r g)) • x := by rfl
      rw [asFinSum]
      rw [Finset.sum_smul]
      apply Submodule.sum_mem
      intro g grsupp
      /-
      have transReprAlgebra : (ρ g) u = ρ.asModuleEquiv (((MonoidAlgebra.single) g (1 : k)) • u') := by
        symm
        calc
          ρ.asModuleEquiv (((MonoidAlgebra.single) g (1 : k)) • u') = (ρ.asAlgebraHom ((MonoidAlgebra.single) g (1 : k))) (ρ.asModuleEquiv u') := by rfl
          _ = (ρ.asAlgebraHom ((MonoidAlgebra.single) g (1 : k))) u := by rfl
          _ = (ρ g) u := by refine LinearMap.congr_fun ?h u; exact asAlgebraHom_single_one ρ g
      -/
      have transAlgebraRepr : (MonoidAlgebra.single g (r g) • x) = (r g) • (ρ g (ρ.asModuleEquiv x)) := by {
        calc
          (MonoidAlgebra.single g (r g) • x) = (ρ.asAlgebraHom (MonoidAlgebra.single g (r g))) (ρ.asModuleEquiv x) := by rfl
          _ = (r g) • (ρ g (ρ.asModuleEquiv x)) := by rw [Representation.asAlgebraHom_single]; simp
      }
      rw [transAlgebraRepr]
      refine Submodule.smul_mem U (r g) ?_
      unfold Representation.IsInvariantSubspace at hU
      apply (hU g ⟨x, by assumption⟩)
    }⟩
    have U'trivial : U' = ⊥ ∨ U' = ⊤ := by exact eq_bot_or_eq_top U'
    have UU'Car : U.carrier = U'.carrier := by rfl
    obtain U'trivial|U'trivial := U'trivial
    . left
      simp
      ext x
      constructor
      . intro xU
        have xU'Car : x ∈ U'.carrier := by
          rw [← UU'Car]
          assumption
        rw [U'trivial] at xU'Car
        simp at xU'Car
        rw [xU'Car]
        rfl
      . intro xBot
        simp at xBot
        rw [xBot]
        exact Submodule.zero_mem U
    . right
      ext x
      constructor
      . intro xU
        exact _root_.trivial
      . intro xTop
        have xUCar : x ∈ U.carrier := by
          rw [UU'Car, U'trivial]
          simp
        assumption
}