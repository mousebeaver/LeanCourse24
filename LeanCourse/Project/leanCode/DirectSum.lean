import Mathlib
import LeanCourse.Project.leanCode.InvariantSubmodules
import LeanCourse.Project.leanCode.IrreducibilityMeansSimpleModule

open Function Set Classical

noncomputable section

namespace Representation

def directSumRepresentation {k G V₁ V₂: Type*}
  [CommSemiring k] [Monoid G] [AddCommMonoid V₁] [AddCommMonoid V₂] [Module k V₁] [Module k V₂]
  (ρ₁: Representation k G V₁) (ρ₂: Representation k G V₂): Representation k G (V₁ × V₂) := {
    toFun := fun g ↦ {
      toFun := fun v ↦ (ρ₁ g (LinearMap.fst k V₁ V₂ v), ρ₂ g (LinearMap.snd k V₁ V₂ v))
      map_add' := by intro x y; simp
      map_smul' := by intro m; simp
    }
    map_one' := by simp; rfl
    map_mul' := by intro g h; simp; rfl
  }

def IsCompletelyReducible {k G V: Type*}
  [CommSemiring k] [Monoid G] [AddCommMonoid V] [Module k V]
  (ρ : Representation k G V) :=
  ∀ U : Submodule k V, IsInvariantSubmodule U ρ → ∃ U' : Submodule k V, IsInvariantSubmodule U' ρ ∧ (IsCompl U U')


theorem maschkeDraft {k G V: Type*}
  [CommSemiring k] [Group G] [Fintype G] [Invertible (Fintype.card G : k)] [AddCommGroup V] [Module k V]
  (ρ: Representation k G V): IsCompletelyReducible ρ := by
  intro U invU
  let UMod := asSubmodule ρ U invU
  have h : ∃ UMod' : Submodule (MonoidAlgebra k G) ρ.asModule, IsCompl UMod UMod' := by
    -- apply exists_isCompl UMod
    sorry
  obtain ⟨UMod', h⟩ := h
  use ofSubmodule ρ UMod'
  constructor
  · exact ofSubmodule_isIrreducible ρ UMod'
  · sorry