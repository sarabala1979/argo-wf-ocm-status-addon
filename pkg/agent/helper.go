package agent

import (
	"fmt"
	argov1alpha1 "github.com/argoproj/argo-workflows/v3/pkg/apis/workflow/v1alpha1"
)

func containsValidOCMLabel(workflow argov1alpha1.Workflow) bool {
	labels := workflow.GetLabels()
	if len(labels) == 0 {
		return false
	}

	uid, ok := labels[LabelKeyHubWorkflowUID]
	return ok && len(uid) > 0
}

func generateHubWorkflowStatusSyncName(workflow argov1alpha1.Workflow) string {
	uid := workflow.GetLabels()[LabelKeyHubWorkflowUID]
	fmt.Println("Hub Workflow UID", uid)
	return uid
}
